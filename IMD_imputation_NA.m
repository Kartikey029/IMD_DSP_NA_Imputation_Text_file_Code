clear; clc;
% Specify the directory (can be modified or prompted)
directory = "E:\PhD\Corrected_name_IMD_DSP\Tamil_nadu_correct"
if isequal(directory, 0) % User canceled the selection
    error('No directory selected.');
end

% Get list of all .txt files in the directory
file_list = dir(fullfile(directory, '*.txt'));

% Process each file
for file_idx = 1:length(file_list)
    original_data_file = fullfile(directory, file_list(file_idx).name);
    % Create output file name by appending '_imputed'
    [~, name, ~] = fileparts(file_list(file_idx).name);
    updated_data_file = fullfile(directory, [name '_imputed.txt']);

    % Open files
    original_file_reader = fopen(original_data_file, 'r');
    updated_file_writer = fopen(updated_data_file, 'w');

    % Process the file
    while ~feof(original_file_reader)
        current_line_text = fgetl(original_file_reader);
        if ischar(current_line_text)
            trimmed_line_text = strtrim(current_line_text);
            if length(trimmed_line_text) >= 7 && all(trimmed_line_text(1:4) >= '0' & trimmed_line_text(1:4) <= '9') && trimmed_line_text(5) == ' ' && all(trimmed_line_text(6:7) >= '0' & trimmed_line_text(6:7) <= '9')
                year_value = str2double(current_line_text(1:4));
                month_value = str2double(current_line_text(6:7));
                daily_rainfall_strings = cell(1, 31);
                for day_number = 1:31
                    field_start_pos = 8 + (day_number - 1) * 7;
                    if field_start_pos + 6 <= length(current_line_text)
                        field_text = current_line_text(field_start_pos : field_start_pos + 6);
                        trimmed_field = strtrim(field_text);
                        if isempty(trimmed_field)
                            daily_rainfall_strings{day_number} = sprintf('%7s', 'NA');
                        else
                            rainfall_value = str2double(trimmed_field);
                            daily_rainfall_strings{day_number} = sprintf('%7.1f', rainfall_value);
                        end
                    else
                        daily_rainfall_strings{day_number} = sprintf('%7s', 'NA');
                    end
                end
                reconstructed_line = sprintf('%4d %02d', year_value, month_value);
                for day_number = 1:31
                    reconstructed_line = [reconstructed_line daily_rainfall_strings{day_number}];
                end
                fprintf(updated_file_writer, '%s\n', reconstructed_line);
            else
                fprintf(updated_file_writer, '%s\n', current_line_text);
            end
        end
    end

    % Close files
    fclose(original_file_reader);
    fclose(updated_file_writer);
    disp(['Processed file saved as: ', updated_data_file]);
end