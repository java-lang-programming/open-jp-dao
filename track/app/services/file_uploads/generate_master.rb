
module FileUploads
  class GenerateMaster
    LEDGER_YAML = 1

    LEDGER_YAML_FIELDS = "fields"

    DEFAULT_LEDGER_YAML_PATH = "lib/file_record/yamls/ledger.yml"

    attr_accessor :kind

    # @param [Integer] kind
    def initialize(kind:)
      @kind = kind
    end

    def master
      # if @kind == LEDGER_YAML
      YAML.load_file("#{Rails.root}/#{DEFAULT_LEDGER_YAML_PATH}")
      # end
      # nil
    end
  end
end
