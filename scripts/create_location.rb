a = ["palermo", "villa urquiza", "chacarita", "flores","retiro","caballito","saavedra","villa del parque","villa devoto","parque chas","parque avellaneda","colegiales","coghlan"]

30.times { p = Post.all[rand(Post.all.count)]; p.location_neighborhood = a[rand(a.count + 1)];p.save!}