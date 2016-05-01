use v6;
use Cache::Role::NodeManipulation;

unit class Cache::LRU does Cache::Role::NodeManipulation;

has Int $.capacity;
has %.data;

method new(Int:D $capacity where { $capacity > 0 }) {
    self.bless(:$capacity);
}

method put(::?CLASS:D: Cool:D $key, Any:D $value --> Bool) {
    if %!data{$key}:exists {
        self.move-node-to-tail(%!data{$key});
        so %!data{$key}.<value> = $value;
    }
    else {
        self.remove($!head.<key>)
            if %!data.keys.elems >= $!capacity;

        my $item = {
            key   => $key,
            value => $value,
            _prev => Nil,
            _next => Nil,
        };

        self.append-node($($item));
        so %!data{$key} = $($item);
    }
}

method get(::?CLASS:D: Cool:D $key --> Any) {
    if %!data{$key}:exists {
        self.move-node-to-tail(%!data{$key});
        %!data{$key}.<value>;
    }
}

method remove(::?CLASS:D: Cool:D $key --> Bool) {
    self.remove-node(%!data{$key})
            if %!data{$key}:exists;
    so %!data{$key}:delete;
}

=begin pod

=head1 NAME

Cache::LRU - "Least Recently Used" caching

=head1 SYNOPSIS

    use Cache::LRU;

    my Cache::LRU $cache .= new(2); # Max capacity: 2

    $cache.put("key1", "value1");   # Sets key1 => value1
    $cache.put("key2", "value2");   # Sets key2 => value2

    $cache.get("key1");             # value1
    $cache.put("key3", "value3");   # Expires key2, and sets key3 => value3

    say $cache.get("key1");  # value1
    say $cache.get("key2");  # Nil
    say $cache.get("key3");  # value3

    $cache.remove("key3");   # True

    say $cache.get("key3");  # Nil

=head1 DESCRIPTION

Cache::FIFO stores key-value cache for up to specified capacity,
while expiring least recently used key when reaching max. capacity.

=head1 METHODS

=head3 new(Int:D $capacity --> Cache::FIFO)

Creates a Cache::LRU instance with specified capacity.

=head3 put(::?CLASS:D: Cool:D $key, Any:D $value --> Bool)

Stores a key-value pair in cache.

=head3 get(::?CLASS:D: Cool:D $key --> Any)

Gets a value for specified in cache.

=head3 remove(::?CLASS:D: Cool:D $key --> Bool)

Removes a key from in cache.

=head1 AUTHOR

yowcow <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
