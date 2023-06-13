module Backy
  class List
    def call
      locals = Set.new(Dir.glob(dump_wildcard))
      remotes = Set.new(S3List.call)

      (locals + remotes).sort.map do |dump_file|
        OpenStruct.new(local?: dump_file.in?(locals), remote?: dump_file.in?(remotes), dump_file:)
      end
    end

    private

    def dump_wildcard
      PgDump::DUMP_DIR + "/*"
    end
  end
end
