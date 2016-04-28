use v6;

unit class Cache::FIFO;

has Int $.max-length;
has Any %.data;
has Hash $.head;
has Hash $.tail;

method new(Int:D $max-length!) {
    self.bless(:$max-length);
}

submethod BUILD(Int:D :$!max-length) {
    die "max-length must be 1 or more"
        if not $!max-length > 0;
}

method all-keys(--> Seq) { %!data.keys }

method put(Cache::FIFO:D: Cool:D $key, Cool:D $value --> Bool) {

    return so %!data{$key}.<value> = $value
        if %!data{$key}:exists;

    self.remove($!head.<key>)
        if %!data.keys.elems >= $!max-length;

    my $item = {
        key   => $key,
        value => $value,
        _prev => Nil,
        _next => Nil,
    };

    if $!tail.defined {
        $!tail.<_next> = $($item);
        $item.<_prev>  = $($!tail);
    }

    $!tail = $($item);
    $!head = $($item)
        if not $!head.defined;

    so %!data{$key} = $($item);
}

method get(Cache::FIFO:D: Cool:D $key --> Any) {
    %!data{$key}.<value>;
}

method remove(Cache::FIFO:D: Cool:D $key --> Bool) {

    return False if not %!data{$key}:exists;

    my $node = %!data{$key};

    $node.<_prev>.<_next> = $node.<_next>
        if $node.<_next>.defined;
    $node.<_next>.<_prev> = $node.<_prev>
        if $node.<_prev>.defined;

    so %!data{$key}:delete;
}
