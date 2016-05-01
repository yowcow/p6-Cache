use v6;
use Cache::LRU;
use Test;

subtest {

    subtest {
        dies-ok { Cache::LRU.new };
        dies-ok { Cache::LRU.new(0) };
        dies-ok { Cache::LRU.new(-1) };

    }, 'Dies with invalid capacity';

    subtest {
        my $c = Cache::LRU.new(1);

        isa-ok $c, 'Cache::LRU';

    }, 'Succeeds with capacity';

}, 'Test instance';

subtest {
    my Cache::LRU $c .= new(1);

    subtest {
        lives-ok { $c.put('key1', 'value1') };
    }, 'put succeeds';

    subtest {
        is $c.get('key1'), 'value1';
    }, 'get returns value';

    subtest {
        ok $c.remove('key1');
    }, 'remove succeeds';

    subtest {
        ok not $c.get('key1').defined;
    }, 'get returns Nil';

}, 'Test put()/get()/remove()';

subtest {
    my Cache::LRU $c .= new(3);
    $c.put('key1', 'value1');
    $c.put('key2', 'value2');
    $c.put('key3', 'value3');

    subtest {
        is $c.head.<key>, 'key1';
        is $c.tail.<key>, 'key3';
        is-deeply $c.all-node-keys, [< key1 key2 key3 >];

    }, 'Keys are in inserted order at first';

    subtest {
        $c.put('key1', 'value11');

        is-deeply $c.all-node-keys, [< key2 key3 key1 >];

    }, 'Setting a duplicated key updates order';

}, 'put() updates key order if duplicated';

subtest {
    my Cache::LRU $c .= new(3);
    $c.put('key1', 'value1');
    $c.put('key2', 'value2');
    $c.put('key3', 'value3');

    subtest {
        is $c.head.<key>, 'key1';
        is $c.tail.<key>, 'key3';
        is-deeply $c.all-node-keys, [< key1 key2 key3 >];

    }, 'Keys are in inserted order at first';

    subtest {
        $c.get('key1');

        is $c.head.<key>, 'key2';
        is $c.tail.<key>, 'key1';
        is-deeply $c.all-node-keys, [< key2 key3 key1 >];

    }, 'Accessing a key updates order';

}, 'get() updates key order';

subtest {
    my Cache::LRU $c .= new(2);
    $c.put('key1', 'value1');
    $c.put('key2', 'value2');
    $c.put('key3', 'value3');

    ok not $c.get('key1').defined;
    is $c.get('key2'), 'value2';
    is $c.get('key3'), 'value3';

}, 'put() removes head node when exceeding capacity';

subtest {
    my Cache::LRU $c .= new(3);
    $c.put('key1', 'value1');
    $c.put('key2', 'value2');
    $c.put('key3', 'value3');

    subtest {
        $c.remove('key2');

        is $c.head.<key>, 'key1';
        is $c.tail.<key>, 'key3';
        is-deeply $c.all-node-keys, [< key1 key3 >];

    }, 'Remove node in the middle';

    subtest {
        $c.remove('key1');

        is $c.head.<key>, 'key3';
        is $c.tail.<key>, 'key3';
        is-deeply $c.all-node-keys, [< key3 >];

    }, 'Remove head node';

    subtest {
        $c.remove('key3');

        ok not $c.head.defined;
        ok not $c.tail.defined;
        is-deeply $c.all-node-keys, [];

    }, 'Remove tail node';

    subtest {
        ok not $c.remove('key3');
    }, 'Remove key already removed';

}, 'remove() removes node';

done-testing;
