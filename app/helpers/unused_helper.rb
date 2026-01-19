module UnusedHelper
  def this_is_never_hit
    Rails.logger.debug "this is never hit"
  end
end
