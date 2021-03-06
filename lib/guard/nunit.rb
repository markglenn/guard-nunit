require 'guard'
require 'guard/guard'
require 'guard/notifier'

module Guard
  class NUnit < Guard

    autoload :MonoRunner, 'guard/nunit/mono_runner'
    autoload :ResultParser, 'guard/nunit/result_parser'
    autoload :Notification, 'guard/nunit/notification'

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      super

      @options = { 
        :all_on_start => true,
        :version => '4.0'
      }.merge( options )
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      UI.info "Guard::NUnit is running"
      run_all if @options[ :all_on_start ]
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
      run_on_change( Dir.glob('**/*\.Tests.dll') )
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_change(paths)
      runner = MonoRunner.new( :version => @options[ :version ] )

      parse_results( runner.execute( paths ) )
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_deletion(paths)
    end

    def parse_results( results )
      parser = ResultParser.new(results)

      puts results

      Notification.notify_results( parser.run_time, parser.tests_run, parser.failures )
      throw :task_has_failed unless parser.is_passing?
    end
  end
end
