[![Build Status](https://travis-ci.org/yowcow/p6-Cache.svg?branch=master)](https://travis-ci.org/yowcow/p6-Cache)

NAME
====

Cache::FIFO - First-in-first-out caching

SYNOPSIS
========

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

DESCRIPTION
===========

Cache::FIFO stores key-value cache for up to specified capacity, while expiring oldest created or updated key when reaching max. capacity.

METHODS
=======

### new(Int:D $capacity --> Cache::FIFO)

Creates a Cache::FIFO instance with specified capacity.

### put(::?CLASS:D: Cool:D $key, Any:D $value --> Bool)

Stores a key-value pair in cache.

### get(::?CLASS:D: Cool:D $key --> Any)

Gets a value for specified in cache.

### remove(::?CLASS:D: Cool:D $key --> Bool)

Removes a key from in cache.

INTERNAL METHODS
================

### all-node-keys(::?CLASS:D: --> Array)

(For testing purpose) Gets an array of keys currently in the node list.

### move-node-to-tail(::?CLASS:D: Hash $node --> Bool)

Moves given node to tail of the node list.

### remove-node(::?CLASS:D: Hash $node --> Bool)

Removes given node from the node list.

AUTHOR
======

yowcow <yowcow@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
