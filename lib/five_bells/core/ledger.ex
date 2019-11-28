defmodule Ledger do
  @account_polarity %{"asset" => -1, "liability" => 1, "equity" => 1}

  defstruct [
    :name,
    ledger_type: "cash",
    account_type: "asset",
    accounts: %{},
    delta: 0
  ]

  #############################################################################
  # Accounts
  #############################################################################

  def add_account(%Ledger{} = ledger), do: add_account(ledger, nil)

  def add_account(%Ledger{} = ledger, account_no) when account_no == nil do
    add_account(ledger, generate_account_no(ledger))
  end

  def add_account(%Ledger{accounts: accounts} = ledger, account_no)
      when is_binary(account_no) do
    case Map.has_key?(accounts, account_no) do
      true ->
        {:error, {:account_exists, account_no}}

      false ->
        {:ok,
         %{
           ledger
           | accounts: Map.put(accounts, account_no, %Account{account_no: account_no})
         }, account_no}
    end
  end

  defp generate_account_no(%Ledger{} = ledger) do
    "#{length(Map.keys(ledger.accounts)) + 1}"
    |> String.pad_leading(4, "0")
  end

  #############################################################################
  # Double-Entry Bookkeeping
  #############################################################################

  def debit(%Ledger{} = ledger, account_no, amount) do
    ledger |> post(account_no, amount * -1)
  end

  def credit(%Ledger{} = ledger, account_no, amount) do
    ledger |> post(account_no, amount)
  end

  defp polarity(%Ledger{} = ledger) do
    case @account_polarity[ledger.account_type] do
      nil -> 0
      polarity -> polarity
    end
  end

  defp post(%Ledger{accounts: accounts} = ledger, account_no, amount) do
    case accounts[account_no] do
      nil ->
        {:error, :account_not_found}

      account ->
        total_amount = account.deposit + amount * polarity(ledger)
        delta = total_amount - account.deposit

        case total_amount < 0 do
          true ->
            {:error, :insufficient_funds}

          false ->
            {:ok,
             %{
               ledger
               | delta: ledger.delta + delta,
                 accounts:
                   Map.update!(ledger.accounts, account_no, fn acc ->
                     %{acc | deposit: total_amount, delta: acc.delta + delta}
                   end)
             }}
        end
    end
  end

  #############################################################################
  # Statistics
  #############################################################################

  def get_deposit_total(%Ledger{} = ledger) do
    Enum.reduce(ledger.accounts, 0, fn {_acc_no, acc}, sum -> sum + acc.deposit end)
  end

  # TODO: loans need to be moved under accounts before attempting this!!!
  # def total(%Ledger{} = ledger) do
  #   case {ledger.ledger_type, ledger.account_type} do
  #   end
  # end

  #############################################################################
  # Cleanup
  #############################################################################

  def reset_deltas(%Ledger{} = ledger) do
    %{
      ledger
      | delta: 0,
        accounts:
          Map.new(ledger.accounts, fn {name, account} -> {name, %{account | delta: 0}} end)
    }
  end
end
