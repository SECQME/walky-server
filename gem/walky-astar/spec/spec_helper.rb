SPEC_DIR = File.expand_path(File.dirname(__FILE__))
ROOT_DIR = File.expand_path(File.join(SPEC_DIR, '..'))
LIB_DIR = File.expand_path(File.join(ROOT_DIR, 'lib'))
FIXTURES_DIR = File.expand_path(File.join(SPEC_DIR, 'fixtures'))

$LOAD_PATH.unshift(SPEC_DIR)
$LOAD_PATH.unshift(LIB_DIR)
$LOAD_PATH.uniq!

require 'walky-astar'
require 'walky-astar/grid'
