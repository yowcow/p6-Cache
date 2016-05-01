use v6;

unit class Cache::FIFO;

has Int $.max-length;
has Any %.data;
has $.head;
has $.tail;

method new(Int:D $max-length!) {
    self.bless(:$max-length);
}

submethod BUILD(Int:D :$!max-length) {
    die "max-length must be 1 or more"
        if not $!max-length > 0;
}

method all-keys(::?CLASS:D: --> Seq) { %!data.keys }

method put(::?CLASS:D: Cool:D $key, Cool:D $value --> Bool) {

    if %!data{$key}:exists {
        self.move-node-to-tail(%!data{$key});
        so %!data{$key}.<value> = $value;
    }
    else {
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
}

method move-node-to-tail(::?CLASS:D: Hash $node --> Bool) {

    # Do nothing if current node is the tail
    return False if $node.<key> ~~ $!tail.<key>;

    # Remove current node from the sequence
    self.remove-node($node);

    # Append current node the the tail
    $!tail.<_next> = $node;
    $node.<_next> = Nil;
    so $!tail = $node;
}

method get(::?CLASS:D: Cool:D $key --> Any) {
    %!data{$key}.<value>;
}

method remove(::?CLASS:D: Cool:D $key --> Bool) {

    return False if not %!data{$key}:exists;

    self.remove-node(%!data{$key});

    so %!data{$key}:delete;
}

method remove-node(::?CLASS:D: Hash $node --> Bool) {

    # If current node is the head, replace head with _next
    if $!head.<key> ~~ $node.<key> {
        $!head = $node.<_next>.defined ?? $node.<_next> !! Nil;
    }
    else {
        $node.<_prev>.<_next> = $node.<_next>;
    }

    # If current node is the tail, replace tail with _prev
    if $!tail.<key> ~~ $node.<key> {
        $!tail = $node.<_prev>.defined ?? $node.<_prev> !! Nil;
    }
    else {
        $node.<_next>.<_prev> = $node.<_prev>;
    }

    True;
}
