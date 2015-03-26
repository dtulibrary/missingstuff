module CurationConcern
  class GenericFilesController < ApplicationController
    include Worthwhile::FilesController
    
    def generic_file_params
      params.require(:generic_file).permit!
    end
  end
end

