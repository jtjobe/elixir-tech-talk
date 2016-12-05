#####
##
##  1. THE BIG PICTURE
##
######

# we're going to look into what happens on line 15 in greater detail

defmodule TcReporter.AgingAccounts do
  alias Decimal, as: D
  use Timex

  def generate_report(user_ids, max_date) do
    file_name = "#{max_date}_#{Enum.join(user_ids, "_")}"
    TcReporter.AgingAccounts.ReportGenerator.make_report(user_ids, max_date)
    |> format_for_csv
    |> TcReporter.Csv.generate_csv(file_name)
    |> TcReporter.Aws.upload_file("aging-accounts", "#{file_name}.csv")
    |> TcReporter.FinancialEmail.send_aging_report
    |> TcReporter.Mailer.deliver_now
  end

  defp format_for_csv(raw_data) do
    periods = ["periods", "1","2","3","4","5","6","7","8","9"]
    first_ifo = ["first_ifo" | raw_data[:first_ifo_values]]
    last_ifo = ["last_ifo" | raw_data[:last_ifo_values]]
    [periods, first_ifo, last_ifo]
  end
end
