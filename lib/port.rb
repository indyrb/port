require 'rubygems'
require 'gosu'
require 'logger'
require 'activesupport'

$: << File.join(File.dirname(__FILE__))

require 'port/ext/array'
require 'port/gosu_extras'
require 'port/vector'
require 'port/game'
require 'port/assets'
require 'port/window'
require 'port/sprite'
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
  
  def initialize
    # options = { :width => 1024, :height => 768, :fullscreen => true } unless ENV['DEBUG']
    self.window = Window.new(self)
  end

  def run
    @window.show
  end

end

