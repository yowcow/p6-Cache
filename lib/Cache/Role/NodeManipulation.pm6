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

method append-node(::?CLASS:D: Hash $node --> Bool) {

    # Exchange tail pointers
    if $!tail.defined {
        $!tail.<_next> = $node;
        $node.<_prev> = $!tail;
    }

    # Given node is the tail!
    $!tail = $node;

    # If no head is defined, this node is the head
    $!head = $node if not $!head.defined;

    True;
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

=begin pod

=head1 NAME

Cache::Role::NodeManipulation - Manipulate cached nodes

=head1 SYNOPSIS

    use Cache::Role::NodeManipulation;

    class MyCache does Cache::Role::NodeManipulation {}

=head1 DESCRIPTION

Cache::Role::NodeManipulation manages nodes in cache instance.

=head1 METHODS

=head3 all-node-keys(::?CLASS:D: --> Array)

Returns an array of "keys" in the node list.

=head3 append-node(::?CLASS:D: Hash $node --> Bool)

Appends given node to tail of the node list.

=head3 move-node-to-tail(::?CLASS:D: Hash $node --> Bool)

Moves given node to tail of the node list.

=head3 remove-node(::?CLASS:D: Hash $node --> Bool)

Removes given node from the node list.

=head1 AUTHOR

yowcow <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
