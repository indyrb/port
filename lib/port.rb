require 'rubygems'
require 'gosu'
require 'logger'
require 'activesupport'

$: << File.join(File.dirname(__FILE__))

require 'port/ext/array'
require 'port/ext/hash'
require 'port/ext/numeric'
require 'port/gosu_extras'
require 'port/vector'
require 'port/polygon'
require 'port/constants'
require 'port/game'
require 'port/assets'
require 'port/window'
require 'port/sprite'
require 'port/moving_sprite'
require 'port/scorable'
require 'port/path'
require 'port/vehicle'
require 'port/smoke'
require 'port/landing_strip'
require 'port/field'
require 'port/cloud'
require 'port/fps_counter'
Dir.glob(File.join(APP_ROOT, 'lib', 'port', 'vehicles', '*.rb')) do |file|
  require file
end

class Application
  attr_accessor :window

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
  
  def initialize(options = {})
    self.window = Window.new(self, options)
  end

  def run
    @window.show
  end

end

