use v6.e.PREVIEW;
unit role WWW::GCloud::RR::Kind;

# Records with "kind" key, like in:
# - https://cloud.google.com/storage/docs/json_api/v1/bucketAccessControls/list#response
# - https://cloud.google.com/storage/docs/json_api/v1/buckets/list#response
has Str $.kind;