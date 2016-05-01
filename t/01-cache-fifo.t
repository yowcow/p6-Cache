use v6;
use Cache::FIFO;
use Test;

subtest {

    subtest {
        dies-ok { Cache::FIFO.new };
    }, 'Dies without max-length';

    subtest {
        dies-ok { Cache::FIFO.new(0) };
    }, 'dies when max-length => 0';

    subtest {
        my Cache::FIFO $cache .= new(2);

        is $cache.max-length, 2;

    }, 'max-length => 2';

}, 'Test instance';

subtest {
    my Cache::FIFO $cache .= new(2);

    ok $cache.put("key1", "value1");
    is $cache.get("key1"), "value1";

    ok $cache.put("key2", "value2");
    is $cache.get("key2"), "value2";

    is-deeply $cache.all-node-keys, ["key1", "key2"];

}, 'Test simple put-get';

subtest {

    subtest {
        my Cache::FIFO $cache .= new(2);

        $cache.put("key1", "value1");
        $cache.put("key2", "value2");
        $cache.put("key3", "value3");

        is $cache.get("key1").defined, False;
        is $cache.get("key2"), "value2";
        is $cache.get("key3"), "value3";

        is-deeply $cache.all-node-keys, ["key2", "key3"];

    }, 'Oldest key expires';

    subtest {
        my Cache::FIFO $cache .= new(2);

        $cache.put("key1", "value1");
        $cache.put("key2", "value2");
        $cache.put("key1", "value11");
        $cache.put("key3", "value3");

        is $cache.get("key1"), "value11";
        is $cache.get("key2").defined, False;

        is-deeply $cache.all-node-keys, ["key1", "key3"];

    }, 'Updated key does not expire';

}, 'Test put exceeds max-length';

subtest {
    my Cache::FIFO $cache .= new(2);

    ok $cache.put("key1", "value1");
    ok $cache.put("key1", "value2");

    is $cache.get("key1"), "value2";
    is-deeply $cache.all-node-keys, ["key1",];

    ok $cache.put("key2", "value2");
    is-deeply $cache.all-node-keys, ["key1", "key2",];

}, 'Test put on dupe key';

subtest {
    my Cache::FIFO $cache .= new(3);

    $cache.put("key1", "value1");
    $cache.put("key2", "value2");
    $cache.put("key3", "value3");

    is $cache.head.<key>, "key1";
    is $cache.tail.<key>, "key3";
    is-deeply $cache.all-node-keys, ["key1", "key2", "key3"];

    ok $cache.remove("key2");
    ok not $cache.get("key2").defined;

    is $cache.head.<key>, "key1";
    is $cache.tail.<key>, "key3";
    is-deeply $cache.all-node-keys, ["key1", "key3"];

    ok $cache.remove("key1");
    ok not $cache.get("key1").defined;

    is $cache.head.<key>, "key3";
    is $cache.tail.<key>, "key3";
    is-deeply $cache.all-node-keys, ["key3"];

    ok $cache.remove("key3");
    ok not $cache.get("key3").defined;

    ok not $cache.head.defined;
    ok not $cache.tail.defined;
    is-deeply $cache.all-node-keys, [];

    ok not $cache.remove("key1"), "Remove item already removed";

}, 'Test remove';

done-testing;
