'use babel';

export const raw = (strings, ...values) => {
  return strings[0].replace(/^[ \t\r]+/gm, "");
};
