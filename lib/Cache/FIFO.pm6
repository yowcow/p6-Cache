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

=begin pod

=head1 NAME

Cache::FIFO - First-in-first-out caching

=head1 SYNOPSIS

    use Cache::FIFO;

    my Cache::FIFO $cache .= new(2); # Max capacity: 2

    $cache.put("key1", "value1");   # Sets key1 => value1
    $cache.put("key2", "value2");   # Sets key2 => value2
    $cache.put("key1", "value1-1"); # Updates key1 => value1-1
    $cache.put("key3", "value3");   # Expires key2, and sets key3 => value3

    say $cache.get("key1");  # value1-1
    say $cache.get("key2");  # Nil
    say $cache.get("key3");  # value3

    $cache.remove("key3");   # True

    say $cache.get("key3");  # Nil

=head1 DESCRIPTION

Cache::FIFO stores key-value cache for up to specified capacity,
while expiring oldest created or updated key when reaching max. capacity.

=head1 METHODS

=head3 new(Int:D $capacity --> Cache::FIFO)

Creates a Cache::FIFO instance with specified capacity.

=head3 put(::?CLASS:D: Cool:D $key, Any:D $value --> Bool)

Stores a key-value pair in cache.

=head3 get(::?CLASS:D: Cool:D $key --> Any)

Gets a value for specified in cache.

=head3 remove(::?CLASS:D: Cool:D $key --> Bool)

Removes a key from in cache.

=head1 INTERNAL METHODS

=head3 all-node-keys(::?CLASS:D: --> Array)

(For testing purpose) Gets an array of keys currently in the node list.

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
