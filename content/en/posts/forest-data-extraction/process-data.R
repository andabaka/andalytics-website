library(readxl)    # For reading Excel files
library(dplyr)     # For data manipulation
library(purrr)     # For functional programming operations
library(stringr)   # For string manipulation
library(ggplot2)   # For visualization
library(rnaturalearth)  # For accessing Natural Earth map data (administrative boundaries)
library(sf)             # For handling spatial vector data and coordinate transformations
library(sp) 

verify_file_structure <- function(file_path) {
    # Use tryCatch to handle potential errors during file processing
    tryCatch({
        # Read the Excel file - no column names as they're not standardized
        raw_data <- read_excel(file_path, sheet = 1, col_names = FALSE)
        
        # Create a results list to store verification outcomes
        results <- list(
            file_name = basename(file_path),    # Just the filename, not full path
            is_valid = TRUE,                    # Initially assume file is valid
            issues = character(0)               # Empty vector to store any issues found
        )
        
        # Initialize flags to track if coordinates were found
        # Will be set to TRUE when valid coordinates are found
        found_x <- FALSE
        found_y <- FALSE
        
        # Loop through each row to find 'x' and 'y' markers and their coordinates
        for(i in 1:nrow(raw_data)) {
            row_data <- raw_data[i,]
            
            # Check for 'x' marker if not already found
            if("x" %in% row_data && !found_x) {
                # Get position of first 'x' in the row
                x_position <- which(row_data == "x")[1]
                # Check if we can look two columns ahead (where coordinate should be)
                if(x_position + 2 <= ncol(raw_data)) {
                    # Try to convert the value two columns after 'x' to numeric
                    x_value <- suppressWarnings(as.numeric(row_data[x_position + 2]))
                    # If conversion successful (not NA), mark as found
                    if(!is.na(x_value)) {
                        found_x <- TRUE
                    }
                }
            }
            
            # Check for 'y' marker if not already found
            if("y" %in% row_data && !found_y) {
                # Get position of first 'y' in the row
                y_position <- which(row_data == "y")[1]
                # Check if we can look two columns ahead
                if(y_position + 2 <= ncol(raw_data)) {
                    # Try to convert the value two columns after 'y' to numeric
                    y_value <- suppressWarnings(as.numeric(row_data[y_position + 2]))
                    # If conversion successful, mark as found
                    if(!is.na(y_value)) {
                        found_y <- TRUE
                    }
                }
            }
            
            # If both coordinates found, no need to check remaining rows
            if(found_x && found_y) break
        }
        
        # Update results if coordinates weren't found
        if(!found_x) {
            results$is_valid <- FALSE
            results$issues <- c(results$issues, 
                                "No valid x-coordinate found two columns after 'x' marker")
        }
        if(!found_y) {
            results$is_valid <- FALSE
            results$issues <- c(results$issues, 
                                "No valid y-coordinate found two columns after 'y' marker")
        }
        
        return(results)
        
    }, error = function(e) {
        # If any error occurs, return error information
        return(list(
            file_name = basename(file_path),
            is_valid = FALSE,
            issues = sprintf("Error reading file: %s", e$message)
        ))
    })
}


verify_all_files <- function(base_path) {
    folders <- list.dirs(base_path, full.names = FALSE, recursive = FALSE)
    total_files <- 0
    valid_files <- 0
    
    for(folder in folders) {
        folder_path <- file.path(base_path, folder)
        excel_files <- list.files(
            path = folder_path,
            pattern = "\\.(xls|xlsx)$",
            full.names = TRUE
        )
        
        total_files <- total_files + length(excel_files)
        folder_results <- lapply(excel_files, verify_file_structure)
        valid_in_folder <- sum(sapply(folder_results, function(x) x$is_valid))
        valid_files <- valid_files + valid_in_folder
    }
    
    # Create a data frame with summary statistics
    summary_df <- data.frame(
        total_files_checked = total_files,
        files_valid = valid_files,
        files_with_issues = total_files - valid_files
    )
    
    # Print summary
    cat("\n=== Verification Summary ===\n")
    cat(sprintf("Total files checked: %d\n", total_files))
    cat(sprintf("Files with valid structure: %d\n", valid_files))
    cat(sprintf("Files with issues: %d\n", total_files - valid_files))
    
    return(summary_df)
}

verify_files <- verify_all_files("content/en/posts/forest-data-extraction/data/")
write.csv(verify_files, "content/en/posts/forest-data-extraction/verify_files.csv", row.names = FALSE)



extract_coordinates <- function(file_path) {
    tryCatch({
        # Read the first sheet without column names
        raw_data <- read_excel(file_path, sheet = 1, col_names = FALSE)
        
        # Initialize variables
        x_coord <- NULL
        y_coord <- NULL
        
        # Find coordinates
        for(i in 1:nrow(raw_data)) {
            # Look for row containing "x"
            if("x" %in% raw_data[i,]) {
                x_row <- i
                x_col <- which(raw_data[i,] == "x")[1]  # Get first occurrence
                if(x_col + 2 <= ncol(raw_data)) {  # Check two columns ahead
                    x_val <- raw_data[x_row, x_col + 2]  # Take value two columns after "x"
                    if(!is.na(x_val)) {
                        x_coord <- as.numeric(x_val)
                    }
                }
            }
            
            # Look for row containing "y"
            if("y" %in% raw_data[i,]) {
                y_row <- i
                y_col <- which(raw_data[i,] == "y")[1]  # Get first occurrence
                if(y_col + 2 <= ncol(raw_data)) {  # Check two columns ahead
                    y_val <- raw_data[y_row, y_col + 2]  # Take value two columns after "y"
                    if(!is.na(y_val)) {
                        y_coord <- as.numeric(y_val)
                    }
                }
            }
        }
        
        # Create result if coordinates were found
        if(!is.null(x_coord) && !is.null(y_coord)) {
            plot_number <- str_extract(basename(file_path), "\\d+-\\d+")
            
            result <- data.frame(
                file_name = basename(file_path),
                plot_number = plot_number,
                folder_name = basename(dirname(file_path)),
                x_coordinate = x_coord,
                y_coordinate = y_coord,
                stringsAsFactors = FALSE
            )
            
            return(result)
        } else {
            warning(sprintf("Could not find coordinates in file: %s", basename(file_path)))
            return(NULL)
        }
    }, error = function(e) {
        warning(sprintf("Error processing file %s: %s", basename(file_path), e$message))
        return(NULL)
    })
}

# Function to process all folders
process_folders <- function(base_path, folder_names = NULL) {
    # If folder_names is NULL, get all folders in base_path
    if(is.null(folder_names)) {
        folder_names <- list.dirs(base_path, full.names = FALSE, recursive = FALSE)
    }
    
    # Create empty list to store results
    all_results <- list()
    
    # Process each folder
    for(folder in folder_names) {
        cat(sprintf("\nProcessing folder: %s\n", folder))
        
        folder_path <- file.path(base_path, folder)
        
        # Get all Excel files in the folder
        excel_files <- list.files(
            path = folder_path,
            pattern = "\\.(xls|xlsx)$",
            full.names = TRUE,
            recursive = FALSE
        )
        
        cat(sprintf("Found %d Excel files\n", length(excel_files)))
        
        # Process each file in the folder
        folder_results <- map_df(excel_files, function(file) {
            cat(sprintf("Processing file: %s\n", basename(file)))
            extract_coordinates(file)
        })
        
        # Add to results list
        all_results[[folder]] <- folder_results
    }
    
    # Combine all results
    final_results <- bind_rows(all_results)
    
    return(final_results)
}


base_path <- "content/en/posts/forest-data-extraction/data/"
folder_names <- c("Delnice", "Gospić", "Ogulin", "Senj")

# Process all folders and extract coordinates
results <- process_folders(base_path)
write.csv(results, "content/en/posts/forest-data-extraction/results.csv", row.names = FALSE)
