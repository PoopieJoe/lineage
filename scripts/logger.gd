extends Node

var target_label: RichTextLabel = null
const log_color: Color = Color.LIGHT_GRAY
const info_color: Color = Color.BLUE
const warning_color: Color = Color.ORANGE
const error_color: Color = Color.RED

var _break_on_error: bool = false
enum {level_debug, level_info, level_warning, level_error}
var _log_level: int = level_warning
var _to_console: bool = true
var _to_file: bool = true
var _log_file_path: String = "logs/latest.log"
var _log_file: FileAccess = null
var _with_timestamp: bool = true

func set_output(label: RichTextLabel) -> void:
    target_label = label
    label.bbcode_enabled = true

func parse_settings(settings_yaml: String) -> void:
    var settings = YAML.parse_file(settings_yaml)["debug"]
    if settings == null:
        error("Could not find 'debug' section in %s, using defaults" % settings_yaml)

    if settings.has("dev_tools"):
        _break_on_error = settings["dev_tools"]["break_on_error"]

    match settings["log_level"].to_lower():
        "debug", "dbg":
            _log_level = level_debug
        "info":
            _log_level = level_info
        "warn", "warning":
            _log_level = level_warning
        "error", "err":
            _log_level = level_error
        _:
            _log_level = level_warning
            error("log_level '%s' could not be parsed, using default '%s'" % [settings["log_level"], "warning"])
        
    if settings.has("output"):
        var output = settings["output"]
        if output.has("to_console"):
            _to_console = output["to_console"]
        if output.has("to_file"):
            _to_file = output["to_file"]
        if _to_file and output.has("file_name"):
            _log_file_path = output["file_name"]
            var dir = DirAccess.open("res://logs")
            if dir.file_exists(_log_file_path):
                dir.remove(_log_file_path)
            _log_file = FileAccess.open(dir.get_current_dir() + "/" + _log_file_path, FileAccess.WRITE)
            if _log_file == null:
                error("Could not open log file at '%s' for writing due to '%s'" % [_log_file_path, FileAccess.get_open_error()])
        else:
            warning("No 'file_path' specified for log output.")
            _to_file = false
        
        if output.has("with_timestamp"):
            _with_timestamp = output["with_timestamp"]

func _init() -> void:
    parse_settings("res://settings.yaml")

func _log(message: String, color: Color) -> void:
    if _with_timestamp:
        var timestamp = "[" + Time.get_time_string_from_system() + "] "
        message = timestamp + message

    if _log_file:
        _log_file.store_line(message)
        _log_file.flush()

    if target_label:
        target_label.append_text("[color=" + color.to_html() + "] > " + message + "\n")
        target_label.scroll_to_line(target_label.get_line_count() - 1)

func debug(message: String) -> void:
    if _log_level < 1:
        print(message)
        _log(message, log_color)

func log(message: String) -> void:
    debug(message)

func info(message: String) -> void:
    if _log_level < 2:
        print(message)
        _log(message, info_color)

func warning(message: String) -> void:
    if _log_level < 3:
        push_warning(message)
        _log(message, warning_color)

func error(message: String) -> void:
    push_error(message)
    _log(message, error_color)
    if _break_on_error:
        breakpoint
