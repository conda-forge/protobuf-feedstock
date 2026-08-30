from google.protobuf import descriptor_pb2
from google.protobuf.internal import api_implementation


message = descriptor_pb2.FileDescriptorProto(
    name="roundtrip.proto",
    package="conda_forge.protobuf",
)
encoded = message.SerializeToString()
decoded = descriptor_pb2.FileDescriptorProto.FromString(encoded)

assert decoded == message
assert api_implementation.Type() == "upb"
