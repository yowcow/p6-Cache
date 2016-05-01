use v6;
use Cache::Role::NodeManipulation;
use Test;

class MyNode does Cache::Role::NodeManipulation {
    method set-head($node --> Bool) { so $!head = $node }
    method set-tail($node --> Bool) { so $!tail = $node }
}

subtest {

    subtest {
        my MyNode $n .= new;

        is-deeply $n.all-node-keys, [];

    }, 'Returns empty array when no head is defined';

    subtest {
        my $node3 = {
            key   => 'node3',
            _next => Nil,
        };
        my $node2 = {
            key   => 'node2',
            _next => $($node3),
        };
        my $node1 = {
            key   => 'node1',
            _next => $($node2),
        };

        my MyNode $n .= new;
        $n.set-head($($node1));

        is-deeply $n.all-node-keys, [< node1 node2 node3 >];

    }, 'Returns keys following nodes';

}, 'Test all-node-keys';

subtest {
    my MyNode $n .= new;

    subtest {
        my $item = { key => 'node1' };

        $n.append-node($($item));

        is $n.head.<key>, 'node1';
        is $n.tail.<key>, 'node1';
        is-deeply $n.all-node-keys, [< node1 >];

    }, 'Set head and tail if list is empty';

    subtest {
        my $item = { key => 'node2' };

        $n.append-node($($item));

        is $n.head.<key>, 'node1';
        is $n.tail.<key>, 'node2';
        is-deeply $n.all-node-keys, [< node1 node2 >];

    }, 'Append to the list';

}, 'Test append-node';

subtest {

    subtest {
        my $node3 = {
            key   => 'node3',
            _next => Nil,
        };
        my $node2 = {
            key   => 'node2',
            _next => $($node3),
        };
        $node3.<_prev> = $($node2);
        my $node1 = {
            key   => 'node1',
            _next => $($node2),
        };
        $node2.<_prev> = $($node1);

        my MyNode $n .= new;
        $n.set-head($($node1));
        $n.set-tail($($node3));

        ok $n.remove-node($node3);
        is $n.head.<key>, 'node1';
        is $n.tail.<key>, 'node2';
        is-deeply $n.all-node-keys, [< node1 node2 >];

    }, 'Removes node in tail';

    subtest {
        my $node3 = {
            key   => 'node3',
            _next => Nil,
        };
        my $node2 = {
            key   => 'node2',
            _next => $($node3),
        };
        $node3.<_prev> = $($node2);
        my $node1 = {
            key   => 'node1',
            _next => $($node2),
        };
        $node2.<_prev> = $($node1);

        my MyNode $n .= new;
        $n.set-head($($node1));
        $n.set-tail($($node3));

        ok $n.remove-node($node2);
        is $n.head.<key>, 'node1';
        is $n.tail.<key>, 'node3';
        is-deeply $n.all-node-keys, [< node1 node3 >];

    }, 'Removes node in the middle';

    subtest {
        my $node3 = {
            key   => 'node3',
            _next => Nil,
        };
        my $node2 = {
            key   => 'node2',
            _next => $($node3),
        };
        $node3.<_prev> = $($node2);
        my $node1 = {
            key   => 'node1',
            _next => $($node2),
        };
        $node2.<_prev> = $($node1);

        my MyNode $n .= new;
        $n.set-head($($node1));
        $n.set-tail($($node3));

        ok $n.remove-node($node1);
        is $n.head.<key>, 'node2';
        is $n.tail.<key>, 'node3';
        is-deeply $n.all-node-keys, [< node2 node3 >];

    }, 'Removes node in head';

}, 'Test remove-node';

subtest {

    subtest {
        my $node3 = {
            key   => 'node3',
            _next => Nil,
        };
        my $node2 = {
            key   => 'node2',
            _next => $($node3),
        };
        $node3.<_prev> = $($node2);
        my $node1 = {
            key   => 'node1',
            _next => $($node2),
        };
        $node2.<_prev> = $($node1);

        my MyNode $n .= new;
        $n.set-head($($node1));
        $n.set-tail($($node3));

        ok not $n.move-node-to-tail($node3);
        is $n.head.<key>, 'node1';
        is $n.tail.<key>, 'node3';
        is-deeply $n.all-node-keys, [< node1 node2 node3 >];

    }, 'The node is already in tail';

    subtest {
        my $node3 = {
            key   => 'node3',
            _next => Nil,
        };
        my $node2 = {
            key   => 'node2',
            _next => $($node3),
        };
        $node3.<_prev> = $($node2);
        my $node1 = {
            key   => 'node1',
            _next => $($node2),
        };
        $node2.<_prev> = $($node1);

        my MyNode $n .= new;
        $n.set-head($($node1));
        $n.set-tail($($node3));

        ok $n.move-node-to-tail($node2);
        is $n.head.<key>, 'node1';
        is $n.tail.<key>, 'node2';
        is-deeply $n.all-node-keys, [< node1 node3 node2 >];

    }, 'The node in the middle goes to tail';

    subtest {
        my $node3 = {
            key   => 'node3',
            _next => Nil,
        };
        my $node2 = {
            key   => 'node2',
            _next => $($node3),
        };
        $node3.<_prev> = $($node2);
        my $node1 = {
            key   => 'node1',
            _next => $($node2),
        };
        $node2.<_prev> = $($node1);

        my MyNode $n .= new;
        $n.set-head($($node1));
        $n.set-tail($($node3));

        ok $n.move-node-to-tail($node1);
        is $n.head.<key>, 'node2';
        is $n.tail.<key>, 'node1';
        is-deeply $n.all-node-keys, [< node2 node3 node1 >];

    }, 'The node in head goes to tail';

}, 'Test move-node-to-tail';

done-testing;
