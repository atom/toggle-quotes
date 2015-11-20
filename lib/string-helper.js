'use babel'

// TODO: Move to underscore-plus?
export const raw = (strings) => {
  return strings[0].replace(/^[ \t\r]+/gm, '')
}
