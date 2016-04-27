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

}, 'Test put-get';

subtest {
    my Cache::FIFO $cache .= new(2);

    $cache.put("key1", "value1");
    $cache.put("key2", "value2");
    $cache.put("key3", "value3");

    is $cache.get("key1").defined, False;
    is $cache.get("key2"), "value2";
    is $cache.get("key3"), "value3";

}, 'Test put exceeds max-length';

subtest {
    my Cache::FIFO $cache .= new(2);

    ok $cache.put("key1", "value1");
    ok $cache.put("key1", "value2");

    is $cache.get("key1"), "value2";
    is-deeply $cache.keys, ["key1"];

    ok $cache.put("key2", "value2");
    is-deeply $cache.keys, ["key1", "key2"];

}, 'Test dupe key';

done-testing;
