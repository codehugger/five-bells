# Non-agent version

# {:ok, bank} = %Bank{} |> Bank.init_customer_bank_ledgers()
# {:ok, bank, account_no} = Bank.open_deposit_account(bank)

# bank =
#   Enum.reduce(1..10, bank, fn cycle, b ->
#     IO.puts("Running loan cycle: #{cycle}")
#     {:ok, b} = Bank.request_loan(b, account_no, 100)
#     {:ok, b} = Bank.pay_loan(b, account_no)
#     b
#   end)

# IO.inspect(bank)

# Agent simulation

{:ok, bank} = BankAgent.start_link()

{:ok, borrower1} =
  BorrowerAgent.start_link(bank: bank, loan_amount: 1200, interest_rate: 10.0, loan_duration: 12)

{:ok, borrower2} =
  BorrowerAgent.start_link(bank: bank, loan_amount: 1200, interest_rate: 10.0, loan_duration: 12)

{:ok, borrower3} =
  BorrowerAgent.start_link(bank: bank, loan_amount: 1200, interest_rate: 10.0, loan_duration: 12)

{:ok, borrower4} =
  BorrowerAgent.start_link(bank: bank, loan_amount: 1200, interest_rate: 10.0, loan_duration: 12)

{:ok, borrower5} =
  BorrowerAgent.start_link(bank: bank, loan_amount: 1200, interest_rate: 10.0, loan_duration: 12)

Enum.each(1..20, fn cycle ->
  BankAgent.evaluate(bank, cycle)
  BorrowerAgent.evaluate(borrower1, cycle)
  BorrowerAgent.evaluate(borrower2, cycle)
  BorrowerAgent.evaluate(borrower3, cycle)
  BorrowerAgent.evaluate(borrower4, cycle)
  BorrowerAgent.evaluate(borrower5, cycle)
end)

IO.inspect(:sys.get_state(bank))
