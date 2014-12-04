module WorthwhileHelper
  include ::BlacklightHelper
  include Worthwhile::MainAppHelpers

  def generic_file_link_name(gf)
    can?(:read, gf) ? generic_file_title(gf) : "File"
  end
end
