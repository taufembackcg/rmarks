#' Internal environment to store mark positions
#' @keywords internal
.mark_env <- new.env(parent = emptyenv())
.mark_env$marks <- list()

#' Internal environment to store mark positions and label
#' @keywords internal
.mark_env <- new.env(parent = emptyenv())
.mark_env$marks <- list()
.mark_env$label <- "🌟 MARK"  # Default label: " MARK"

#' Add a visual mark at the current line
#'
#' Adds a numbered mark (0-9) to the current line of the active document,
#' and inserts a visual comment like `#  MARK N`. If a previous mark with
#' the same number exists, it will be removed and replaced.
#'
#' @param number A single digit from 0 to 9 indicating the mark number.
#' @keywords internal
add_mark_generic <- function(number) {
  ctx <- rstudioapi::getActiveDocumentContext()
  file <- ctx$path
  line <- ctx$selection[[1]]$range$start["row"]
  col <- ctx$selection[[1]]$range$start["column"]

  .mark_env$marks[[as.character(number)]] <- list(file = file, line = line)

  label <- .mark_env$label
  mark_text <- paste0("# ", label, " ", number)
  mark_pattern <- paste0("# ", label, " ", number)

  lines <- ctx$contents
  new_lines <- lines[!grepl(mark_pattern, lines, fixed = TRUE)]

  insert_pos <- min(line, length(new_lines) + 1)
  new_lines <- append(new_lines, mark_text, after = insert_pos - 1)

  rstudioapi::setDocumentContents(paste(new_lines, collapse = "\n"))
  rstudioapi::setCursorPosition(rstudioapi::document_position(insert_pos, col))
}

#' Set the default label text for marks
#'
#' Opens a prompt to let the user change the default label used in mark comments.
#' @export
set_mark_label <- function() {
  input <- rstudioapi::showPrompt(
    title = "Set Default Mark Label",
    message = "Enter label to use in marks (e.g.,  MARK):",
    default = .mark_env$label
  )

  if (is.null(input) || input == "") return()

  .mark_env$label <- input
  rstudioapi::showDialog("Mark Label Updated", paste("New label set to:", input))
}


#' Jump to a previously set mark
#'
#' Moves the cursor to the line where the specified mark was saved.
#' If the mark doesn't exist, nothing happens.
#'
#' @param number A single digit from 0 to 9.
#' @keywords internal
goto_mark_generic <- function(number) {
  mark <- .mark_env$marks[[as.character(number)]]
  if (is.null(mark)) return()
  rstudioapi::navigateToFile(mark$file, line = mark$line)
}

#' Remove all visual marks from the current document
#'
#' Deletes all `# <LABEL> N` comments and clears memory of saved marks.
#'
#' @export
clean_all_marks <- function() {
  ctx <- rstudioapi::getActiveDocumentContext()
  lines <- ctx$contents
  line <- ctx$selection[[1]]$range$start["row"]
  col <- ctx$selection[[1]]$range$start["column"]

  label <- .mark_env$label
  # We'll match any mark from 0-9 using a loop and fixed matching
  patterns <- paste0("# ", label, " ", 0:9)

  keep <- !vapply(lines, function(l) any(startsWith(l, patterns)), logical(1))
  new_lines <- lines[keep]

  rstudioapi::setDocumentContents(paste(new_lines, collapse = "\n"))
  rstudioapi::setCursorPosition(rstudioapi::document_position(line, col))
  .mark_env$marks <- list()
}



#' @keywords internal
make_add_mark <- function(n) {
  force(n)
  function() add_mark_generic(n)
}

#' @keywords internal
make_goto_mark <- function(n) {
  force(n)
  function() goto_mark_generic(n)
}

for (n in 0:9) {
  fn_add <- make_add_mark(n)
  fn_goto <- make_goto_mark(n)
  assign(paste0("add_mark_", n), fn_add)
  assign(paste0("goto_mark_", n), fn_goto)
}

#' Remove a specific mark by number (prompt-based)
#'
#' Prompts the user to enter a mark number (0-9) and removes the corresponding mark
#' and comment line from the current document and memory.
#'
#' @export
remove_mark_prompt <- function() {
  input <- rstudioapi::showPrompt(
    title = "Remove Mark",
    message = "Enter a mark number to remove (0-9):",
    default = ""
  )

  if (is.null(input)) return()
  if (!grepl("^[0-9]$", input)) {
    rstudioapi::showDialog("Invalid Input", "Please enter a single digit from 0 to 9.")
    return()
  }

  number <- as.integer(input)

  ctx <- rstudioapi::getActiveDocumentContext()
  lines <- ctx$contents
  label <- .mark_env$label
  mark_pattern <- paste0("# ", label, " ", number)

  new_lines <- lines[!grepl(mark_pattern, lines, fixed = TRUE)]

  rstudioapi::setDocumentContents(paste(new_lines, collapse = "\n"))
  .mark_env$marks[[as.character(number)]] <- NULL
}



#' @export
add_mark_0
#' @export
add_mark_1
#' @export
add_mark_2
#' @export
add_mark_3
#' @export
add_mark_4
#' @export
add_mark_5
#' @export
add_mark_6
#' @export
add_mark_7
#' @export
add_mark_8
#' @export
add_mark_9

#' @export
goto_mark_0
#' @export
goto_mark_1
#' @export
goto_mark_2
#' @export
goto_mark_3
#' @export
goto_mark_4
#' @export
goto_mark_5
#' @export
goto_mark_6
#' @export
goto_mark_7
#' @export
goto_mark_8
#' @export
goto_mark_9
