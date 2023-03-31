import sys
import time
import yaml

def main(in_file, out_file):
    with open(in_file, 'r', encoding='utf-8') as open_file:
        obj = yaml.safe_load(open_file)
        OBJECTS = obj['objects']
        NAME = obj['name']
        VERSION = obj['version'].replace('.', '_').capitalize()

    OUT_FILE = out_file
    if OUT_FILE.endswith('.elm'):
        OUT_FILE = OUT_FILE[:-4]

    encapsulate = lambda s : s if ' ' not in s else '(' + s + ')'

    # Boolean
    class BoolField:
        @property
        def type_name(self):
            return 'Bool'
        
        @property
        def encoder(self):
            return 'E.bool'
        
        @property
        def decoder(self):
            return 'D.bool'

    # Integer
    class IntField:
        @property
        def type_name(self):
            return 'Int'
        
        @property
        def encoder(self):
            return 'E.int'
        
        @property
        def decoder(self):
            return 'D.int'

    # String
    class StringField:
        @property
        def type_name(self):
            return 'String'
        
        @property
        def encoder(self):
            return 'E.string'
        
        @property
        def decoder(self):
            return 'D.string'

    # Float: should be avoided as it isn't allowed for canonical JSON.
    class FloatField:
        @property
        def type_name(self):
            return 'Float'
        
        @property
        def encoder(self):
            return 'E.float'
        
        @property
        def decoder(self):
            return 'D.float'

    # Timestamp
    class TimestampField:
        @property
        def type_name(self):
            return 'Timestamp'
        
        @property
        def encoder(self):
            return 'encodeTimestamp'
        
        @property
        def decoder(self):
            return 'timestampDecoder'

    # JSON Value
    class ValueField:
        @property
        def type_name(self):
            return 'E.Value'
        
        @property
        def encoder(self):
            return ''
        
        @property
        def decoder(self):
            return 'D.value'

    # Enum
    class EnumField:
        def __init__(self, name) -> None:
            self.name = name

        @property
        def type_name(self):
            return 'Enums.' + self.name

        @property
        def encoder(self):
            return 'Enums.encode' + self.name

        @property
        def decoder(self):
            return 'Enums.' + self.name[0].lower() + self.name[1:] + 'Decoder'

    # Another object
    class SpecObjectField:
        def __init__(self, name) -> None:
            self.name = name
        
        @property
        def type_name(self):
            return self.name
        
        @property
        def encoder(self):
            return 'encode' + self.type_name

        @property
        def decoder(self):
            decoder_name = self.type_name[0].lower() + self.type_name[1:] + 'Decoder'

            if 'anti_recursion' in OBJECTS[self.name]:
                return f'D.lazy (\_ -> {decoder_name})'
            else:
                return decoder_name

    # List of fields
    class ListField:
        def __init__(self, child_field):
            self.child = child_field
        
        @property
        def type_name(self):
            return 'List ' + encapsulate(self.child.type_name)
        
        @property
        def encoder(self):
            return 'E.list ' + encapsulate(self.child.encoder)
        
        @property
        def decoder(self):
            return 'D.list ' + encapsulate(self.child.decoder)

    # Dict of string -> fields
    class DictField:
        def __init__(self, child_field):
            self.child = child_field
        
        @property
        def type_name(self):
            return 'Dict String ' + encapsulate(self.child.type_name)
        
        @property
        def encoder(self):
            return 'E.dict identity ' + encapsulate(self.child.encoder)
        
        @property
        def decoder(self):
            return 'D.dict ' + encapsulate(self.child.decoder)

    def str_to_field(value : str):
        if value.startswith('[') and value.endswith(']'):
            return ListField(str_to_field(value[1:-1]))
        if value.startswith('{') and value.endswith('}'):
            return DictField(str_to_field(value[1:-1]))
        if value in OBJECTS:
            return SpecObjectField(value)
        if value.startswith('Enums.'):
            return EnumField(value[len('Enums.'):])
        
        match value:
            case 'value':
                return ValueField()
            case 'bool':
                return BoolField()
            case 'int':
                return IntField()
            case 'string':
                return StringField()
            case 'float':
                return FloatField()
            case 'timestamp':
                return TimestampField()

        raise ValueError("Unknown value `" + value + "`")

    class Field:
        def __init__(self, key, value):
            self.key = key

            self.field = str_to_field(value['type'])
            self.required = False
            if 'required' in value:
                self.required = value['required']
            if not self.required:
                self.default = None if 'default' not in value else value['default']
        
        @property
        def elm_name(self):
            if self.key == 'type':
                return 'eventType'
            else:
                words = self.key.lower().replace('_', ' ').replace('.', ' ').split(' ')
                words = ''.join([w.capitalize() for w in words])
                words = words[0].lower() + words[1:]
                return words

        @property
        def encoder(self):
            if self.required == 'never':
                return 'Nothing'
            elif self.required == 'now':
                return (
                    'Maybe.map ' + encapsulate(self.field.encoder) + ' data.' + self.elm_name
                )
            elif self.required or self.default is not None:
                return (
                    'Just <| ' + self.field.encoder + ' data.' + self.elm_name
                )
            elif self.field.__class__ == ValueField:
                return 'data.' + self.elm_name
            else:
                return (
                    'Maybe.map ' + encapsulate(self.field.encoder) + ' data.' + self.elm_name
                )
        
        @property
        def decoder(self):
            if self.required == 'never':
                return 'D.succeed Nothing'
            elif self.required == 'now':
                field = f'D.map Just <| D.field "{self.key}"'
            elif self.required:
                field = f'D.field "{self.key}"'
            elif self.default is None:
                field = f'opField "{self.key}"'
            else:
                field = f'opFieldWithDefault "{self.key}" {self.default}'
            
            return f'{field} {encapsulate(self.field.decoder)}'

        @property
        def type_definition(self):
            if self.required in ['now', 'never']:
                return 'Maybe ' + encapsulate(self.field.type_name)
            elif self.required or self.default is not None:
                return self.field.type_name
            else:
                return 'Maybe ' + encapsulate(self.field.type_name)

    class Object:
        def __init__(self, key, value):
            self.name = key
            self.description = value['description']
            self.anti_recursion = 'anti_recursion' in value
            self.fields = []

            for k in sorted(value['fields'].keys()):
                v = value['fields'][k]
                self.fields.append(Field(k, v))
        
        @property
        def elm_name(self):
            if '.' not in self.name:
                return self.name
            else:
                return ''.join([word.capitalize() for word in self.name.split('.')])
        
        @property
        def lowercase_elm_name(self):
            n = self.elm_name
            return n[0].lower() + n[1:]
        
        @property
        def encoder_name(self):
            return 'encode' + self.elm_name
        
        @property
        def decoder_name(self):
            return self.lowercase_elm_name + 'Decoder'
        
        @property
        def encoder(self):
            return (
                f"{self.encoder_name} : {self.elm_name} -> E.Value\n" +
                f"{self.encoder_name} " + (f'({self.elm_name} data)' if self.anti_recursion else 'data') + " =\n" +
                f"    maybeObject [\n" +
                ',\n'.join(f'        ("{f.key}", {f.encoder})' for f in self.fields) +
                f"\n            ]\n" +
                f"\n\n"
            )

        @property
        def decoder(self):
            return (
                f"{self.decoder_name} : D.Decoder {self.elm_name}\n" +
                f"{self.decoder_name} =\n" +
                f"    D.map{len(self.fields)}\n".replace('D.map1\n', 'D.map\n') +
                f"        (\\" + ' '.join(["abcdefghijklmnop"[i] for i in range(len(self.fields))]) + ' ->\n' +
                f"            " + (self.elm_name if self.anti_recursion else '') + " { " + ', '.join([self.fields[i].elm_name + '=' + "abcdefghijklmnop"[i] for i in range(len(self.fields))]) + '})\n' +
                ''.join(f"            " + encapsulate(f.decoder) + '\n' for f in self.fields) +
                f"\n\n"
            )
        
        @property
        def type_definition(self):
            return (
                "{-| " + self.description + "\n-}\ntype " +
                ('alias' if not self.anti_recursion else '') + f" {self.elm_name} = " + (self.elm_name if self.anti_recursion else "" ) +
                " {\n" + ',\n'.join(f"    {f.elm_name} : {f.type_definition}" for f in self.fields) +
                '\n' + "    }\n\n"
            )

    object_list = [Object(name, val) for name, val in OBJECTS.items()]
    object_list.sort(key=lambda o : o.elm_name.lower())

    with open(OUT_FILE + '.elm', 'w') as write_file:
        write = write_file.write

        write(f"module {OUT_FILE[4:].replace('/', '.')} exposing (\n    ".replace('\\', '.') )
        imports = [f"{o.elm_name + '(..)' if o.anti_recursion else o.elm_name}\n    , {o.encoder_name}\n    , {o.decoder_name}" for o in object_list]
        write('\n    , '.join(imports) + "\n    )\n")
        write("{-| Automatically generated '" + NAME + "'\n\nLast generated at Unix time ")
        write(str(int(time.time())) + "\n-}\n\n")


        content = ''.join([o.type_definition + o.encoder + o.decoder for o in object_list])
        
        write("\n")
        if 'Dict' in content:
            write("import Dict exposing (Dict)\n")
        
        module_name = 'Internal.Tools.DecodeExtra'
        if 'map9' in content or 'map10' in content or 'map11' in content:
            module_name = 'Internal.Tools.DecodeExtra as D'

        if 'opField ' in content and 'opFieldWithDefault ' in content:
            write(f"import {module_name} exposing (opField, opFieldWithDefault)\n")
        elif 'opFieldWithDefault ' in content:
            write(f"import {module_name} exposing (opFieldWithDefault)\n")
        elif 'opField ' in content:
            write(f"import {module_name} exposing (opField)\n")
        
        if 'maybeObject' in content:
            write("import Internal.Tools.EncodeExtra exposing (maybeObject)\n")
        
        if 'Timestamp' in content:
            write("import Internal.Tools.Timestamp exposing (Timestamp, encodeTimestamp, timestampDecoder)\n")
        
        if 'Enums' in content:
            write("import Internal.Tools.SpecEnums as Enums\n")

        write("""
import Json.Decode as D
import Json.Encode as E

""")

        write(content)
        
    print(f'Generated file {out_file}!')

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])