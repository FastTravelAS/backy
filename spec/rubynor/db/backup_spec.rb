# frozen_string_literal: true

RSpec.describe Rubynor::DB::Backup do
  it "has a version number" do
    expect(Rubynor::DB::Backup::VERSION).not_to be nil
  end
end
