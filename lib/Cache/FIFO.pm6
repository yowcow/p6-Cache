use v6;

unit class Cache::FIFO;

has Int $.max-length;
has %.data;
has @.keys;

method new(Int:D $max-length!) {
    self.bless(:$max-length);
}

submethod BUILD(Int:D :$!max-length) {
    die "max-length must be 1 or more"
        if not $!max-length > 0;
}

method put(Cache::FIFO:D: Cool:D $key, Cool:D $value --> Bool) {

    if !(%!data{$key}:exists) {
        %!data{@!keys.shift}:delete
            if @!keys.elems >= $!max-length;
        @!keys.push: $key;
    }

    so %!data{$key} = $value;
}

method get(Cache::FIFO:D: Cool:D $key --> Any) {
    %!data{$key};
}

method remove(Cache::FIFO:D: Cool:D $key --> Bool) {

    return False if not %!data{$key}:exists;

    %!data{$key}:delete;
    @!keys.splice: @!keys.first($key, :k), 1;

    True;
}
