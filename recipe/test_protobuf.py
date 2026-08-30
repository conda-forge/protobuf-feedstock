from google.protobuf import descriptor_pb2, wrappers_pb2
from google.protobuf.internal import api_implementation


message = descriptor_pb2.FileDescriptorProto(
    name="roundtrip.proto",
    package="conda_forge.protobuf",
)
encoded = message.SerializeToString()
decoded = descriptor_pb2.FileDescriptorProto.FromString(encoded)

assert decoded == message

large_value = wrappers_pb2.UInt64Value(value=(1 << 63) + 123)
large_value_encoded = large_value.SerializeToString()
large_value_decoded = wrappers_pb2.UInt64Value.FromString(large_value_encoded)

assert large_value_decoded == large_value
assert api_implementation.Type() == "upb"
