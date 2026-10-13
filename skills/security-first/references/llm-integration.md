# Integrating an AI model safely

## Division of labor

- **The model proposes; a person accepts.** Text, classifications and suggestions go
  through a human decision before they count.
- **The model never produces a number that must be correct.** Figures come from
  deterministic, published formulas. The model may explain them, never compute them.
- **The product works without the model.** The AI feature is off by default and the
  core keeps working when it is off, unreachable or out of budget.

## Data

- **Minimize what is sent.** Strip names, IDs, tax numbers and free text that is not
  needed. Test it: the outgoing request must not contain the test company's name or ID.
- **Sending data to a model is data leaving the machine.** It needs explicit,
  per-feature, revocable consent.
- **The API key** lives in an environment variable or the OS keychain. Never in the
  repository, the user's data files or the logs.

## Output

- **Treat model output as hostile input.** Validate it against a schema, encode it on
  render and never execute it.
- **Prompt injection arrives through data.** A document or field can contain
  instructions. Keep instructions and data separate and never let output trigger
  actions without confirmation.

## Testing

- **Never call the real API from tests.** Point the client at a local fake HTTP server
  that imitates the API. You can check the request shape, parse the response, and
  simulate errors and batch endpoints with no network, no real key and no cost.
- When the SDK uses a different version of a JSON library than the app, both can
  coexist. Check which annotations the SDK expects.

## Cost and reproducibility

- Set budget limits and handle 429 and 5xx errors with backoff.
- Record the model ID and prompt version next to any AI-assisted output, so a result
  can be traced back to what produced it.
