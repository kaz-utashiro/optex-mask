
# NAME

App::optex::mask - optex data masking module

# SYNOPSIS

    optex -Mmask patterns -- --mask=deepl command

# DESCRIPTION

App::optex::mask is an **optex** module for masking data given as
standard input to a command to be executed. It transforms strings
matching a specified pattern according to a set of rules before giving
them as input to a command, and restores the resulting content to the
original string.

Multiple conversion rules can be specified, but currently only
`deepl` is supported. The `deepl` rule converts a string to an XML
tag such as `<m id=999 />`.

# LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Kazumasa Utashiro
