export const OPTIONS = {
  SEPARATE_BULL : 1,
  MASTER_OUT    : 2
};

export function hasOption(options_value, option) {
  return (options_value & option) !== 0;
}
