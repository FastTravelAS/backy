module Backy
  class List
    def call
      locals = Set.new(Dir.glob(dump_wildcard))
      remotes = Set.new(S3List.new.call)

      (locals + remotes).sort.map do |dump_file|
        OpenStruct.new(local?: locals.include?(dump_file), remote?: remotes.include?(dump_file), dump_file: dump_file)
      end
    end

    private

    def dump_wildcard
      PgDump::DUMP_DIR + "/*"
    end
  end
end
