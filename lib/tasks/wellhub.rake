namespace :wellhub do
  desc "Mark stale Wellhub bookings as no-show for past classes. Use DRY_RUN=1 to preview without changes."
  task cleanup_stale_bookings: :environment do
    dry_run = ENV["DRY_RUN"].present?

    from_date = ENV.fetch("FROM", "2026-03-31").to_date
    to_date   = ENV.fetch("TO", Date.current.to_s).to_date

    stale_bookings = WellhubBooking
      .accepted
      .joins(:studio_class)
      .where("studio_classes.date >= ? AND studio_classes.date < ?", from_date, Date.current)

    puts "Date range: #{from_date} to #{to_date}"

    total = stale_bookings.count
    puts dry_run ? "[DRY RUN] Would affect #{total} stale booking(s)." : "Found #{total} stale Wellhub booking(s) for past classes."

    if total == 0
      puts "Nothing to clean up."
      next
    end

    cancelled = 0
    errors = []

    stale_bookings.find_each do |booking|
      label = "booking ##{booking.booking_number} (class #{booking.studio_class.date}, id=#{booking.studio_class_id})"

      if dry_run
        puts "  Would cancel #{label}"
        cancelled += 1
        next
      end

      ActiveRecord::Base.transaction do
        studio_class = booking.studio_class
        studio_class.lock!

        booking.no_show!

        if studio_class.date >= Date.current && studio_class.spots_remaining < studio_class.capacity
          studio_class.increment!(:spots_remaining)
        end
      end

      cancelled += 1
      puts "  Cancelled #{label}"
    rescue => e
      errors << { booking_number: booking.booking_number, error: e.message }
      puts "  ERROR on #{label}: #{e.message}"
    end

    puts "=" * 60
    if dry_run
      puts "[DRY RUN] Would cancel #{cancelled}/#{total} stale bookings. No changes were made."
    else
      puts "Done. Cancelled #{cancelled}/#{total} stale bookings."
      puts "No Wellhub API calls were made — Wellhub already has the correct state."
    end
    puts "Errors: #{errors.size}" if errors.any?
  end
end
