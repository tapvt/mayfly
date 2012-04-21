{application,cheea,
             [{description,"An erlang cowboy-based app."},
              {vsn,"0.1.0"},
              {modules,[cheea,cheea_sup,default_handler,index_dtl]},
              {registered,[cheea_sup]},
              {applications,[kernel,stdlib,crypto,public_key,ssl,cowboy]},
              {mod,{cheea,[]}},
              {env,[]}]}.
