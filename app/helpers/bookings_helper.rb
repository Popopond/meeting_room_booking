module BookingsHelper
  def time_options_for_select
    options = []
    (8..18).each do |hour|
      [ "00", "30" ].each do |minute|
        time = "#{hour.to_s.rjust(2, '0')}:#{minute}"
        options << [ time, time ]
      end
    end
    options
  end
end
