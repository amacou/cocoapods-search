require 'spec_helper'

describe Cocoapods::Search::Cli do
  context '#search' do
    before do
      @cli = Cocoapods::Search::Cli.new
    end

    context 'with nonexistance pods' do
      before do
        Open3.should_receive(:capture3).and_return(
          [dummy_pod_search_nothing, '', double(success?: false)])
      end
      it 'should raise LibraryNotFound' do
        expect{ @cli.search('no_match_pod_name') }.to raise_error(Cocoapods::Search::LibraryNotFound)
      end
    end

    context 'updating repository' do
      before do
        Open3.should_receive(:capture3).and_return(
          ["Setting up CocoaPods master repo\Updating 64e7f15..96d38c5", 'stderr', double(success?: true)])
      end
      it 'should raise PodError' do
        expect{ @cli.search('when updating repository') }.to raise_error(Cocoapods::Search::OldRepositoryError)
      end
    end

    context 'occored pods error' do
      before do
        Open3.should_receive(:capture3).and_return(
          ['stdout', 'stderr', double(success?: false)])
      end
      it 'should raise PodError' do
        expect{ @cli.search('when error occured') }.to raise_error(Cocoapods::Search::PodError)
      end
    end

    context 'with exisiting pods' do
      before do
        stub_request_on_github 'https://github.com/AaronBratcher/ABSQLite'
        stub_request_on_github 'https://github.com/dodikk/CsvToSqlite'
        stub_request_on_github 'https://github.com/youknowone/sqlite3-objc'
        Open3.should_receive(:capture3).and_return([dummy_pod_search_result, '', double(success?: true)])
      end

      it 'should display pods ordering by score' do
        expect(capture(:stdout) { @cli.search('sqlite') }).to eq <<-'EOS'.gsub(/^\s+\|/, '')
          |Name(Ver)                                 Score  Star  Fork
          |---------------------------------------- ------ ----- -----
          |CsvToSqlite (1.0)                            42    17     5
          |sqlite3-objc (0.2)                           17    12     1
          |ABSQLite (1.2.0)                              5     5     0
          |sqlite3 (3.8.4.3)                             -     -     -
        EOS
      end
    end
  end

  private
    def dummy_pod_search_nothing
      "[!] Unable to find a pod with name matching `no_match_pod_name'"
    end

    def dummy_pod_search_result
      <<-'EOS'.gsub(/^\s+\|/, '')
        |
        |
        |-> ABSQLite (1.2.0)
        |   ABSQLite is an Objective-C wrapper to SQLite making it easy to use the database.
        |   pod 'ABSQLite', '~> 1.2.0'
        |   - Homepage: https://github.com/AaronBratcher/ABSQLite
        |   - Source:   https://github.com/AaronBratcher/ABSQLite.git
        |   - Versions: 1.2.0, 1.1.0 [master repo]
        |
        |
        |-> CsvToSqlite (1.0)
        |   An iOS library to import a CSV file to the SQLite table
        |   pod 'CsvToSqlite', '~> 1.0'
        |   - Homepage: https://github.com/dodikk/CsvToSqlite
        |   - Source:   https://github.com/dodikk/CsvToSqlite.git
        |   - Versions: 1.0 [master repo]
        |
        |
        |-> sqlite3 (3.8.4.3)
        |   SQLite is an embedded SQL database engine.
        |   pod 'sqlite3', '~> 3.8.4.3'
        |   - Homepage: http://www.sqlite.org
        |   - Source:   http://www.sqlite.org/2014/sqlite-amalgamation-3080403.zip
        |   - Versions: 3.8.4.3, 3.8.4.2, 3.8.4.1, 3.8.1, 3.8.0.2, 3.8.0, 3.7.17.0, 3.7.16.2, 3.7.16.1, 3.7.16, 3.7.15.2,
        |   3.7.15.1, 3.7.15, 3.7.14.1 [master repo]
        |   - Sub specs:
        |     - sqlite3/common (3.8.4.3)
        |     - sqlite3/fts (3.8.4.3)
        |     - sqlite3/unicode61 (3.8.4.3)
        |     - sqlite3/coldata (3.8.4.3)
        |     - sqlite3/unlock_notify (3.8.4.3)
        |     - sqlite3/rtree (3.8.4.3)
        |     - sqlite3/stat3 (3.8.4.3)
        |     - sqlite3/stat4 (3.8.4.3)
        |     - sqlite3/soundex (3.8.4.3)
        |
        |
        |-> sqlite3-objc (0.2)
        |   Sqlite3 Objective-C wrapper.
        |   pod 'sqlite3-objc', '~> 0.2'
        |   - Homepage: https://github.com/youknowone/sqlite3-objc
        |   - Source:   https://github.com/youknowone/sqlite3-objc.git
        |   - Versions: 0.2 [master repo]
      EOS
    end
end