use v6;

unit class Cache::FIFO;

has Int $.max-length;
has Any %.data;
has Any @!keys;

method new(Int:D $max-length!) {
    self.bless(:$max-length);
}

submethod BUILD(Int:D :$!max-length) {
    die "max-length must be 1 or more"
        if not $!max-length > 0;
}

method put(Cache::FIFO:D: Cool:D $key, Cool:D $value --> Bool) {
    %!data{@!keys.shift}:delete
        if @!keys.elems >= $!max-length;

    @!keys.push: $key;

    so %!data{$key} = $value;
}

method get(Cache::FIFO:D: Cool:D $key --> Any) {
    %!data{$key};
}
