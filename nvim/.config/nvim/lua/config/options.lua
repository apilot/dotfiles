-- This file has been refactored into modular configuration
-- Content moved to:
-- - lua/config/editor.lua - Basic editor settings
-- - lua/config/neovide.lua - GUI specific settings
-- - lua/config/languages.lua - Language specific configurations

-- This file is kept for backward compatibility but can be removed
-- after confirming the new modular structure works correctly

print("Warning: options.lua has been refactored. Configuration is now loaded from modular files in lua/config/")