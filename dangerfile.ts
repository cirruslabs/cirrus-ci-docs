import { message, warn, fail, markdown, danger } from "danger"

if (
    !danger.git.fileMatch("docs/*.md").modified
    && !danger.git.fileMatch("docs/**/*.md").modified
) {
    message("No documentation has been actually changed.")
}

if (danger.git.fileMatch(".cirrus.yml").modified) {
    message("CI system updated.")
}

if (danger.git.fileMatch(".ci/*.*").modified) {
    message("Docs deploy system updated.")
}

if (danger.git.fileMatch("docs/legal/*.md").modified) {
    warn("Legal pages modified!")
}

if (danger.github.pr.body.length <= 4) {
    fail("Please put a larger description in your PR's body!")
} else {
    message("PR description looks good.")
}

message(":smile: Thanks for contributing!")

markdown("> I am an automated review bot.")
