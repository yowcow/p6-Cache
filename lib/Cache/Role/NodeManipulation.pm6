use v6;

unit role Cache::Role::NodeManipulation;

has $.head;
has $.tail;

method all-node-keys(::?CLASS:D: --> Array) {

    return [] if not $!head.defined;

    my @keys;
    my $node = $!head;

    while $node.defined {
        @keys.push: $node.<key>;
        $node = $node.<_next>;
    }

    @keys;
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
