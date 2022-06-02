-- lualine config
require('lualine').setup({
        options = {
            theme = 'dracula'
        },
        sections = {
            lualine_c = {
                {
                    'filename',
                    path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
                }
            }
        },
        extensions = {'quickfix', 'fugitive'}
    })
