def upsert_category!(heading, slug:, parent: nil, overview: '')
  Category.where(slug: slug).first_or_create!(
    heading:   heading,
    overview:  overview,
    parent_id: parent&.id
  )
end

roots = {}
roots[:iphone]   = upsert_category!('iPhone',                 slug: 'iphone')
roots[:ipad]     = upsert_category!('iPad',                   slug: 'ipad')
roots[:mac]      = upsert_category!('Mac',                    slug: 'mac')
roots[:watch]    = upsert_category!('Apple Watch',            slug: 'apple-watch')
roots[:audio]    = upsert_category!('AirPods & Audio',        slug: 'audio')
roots[:tvhome]   = upsert_category!('TV & Home',              slug: 'tv-home')
roots[:ipod]     = upsert_category!('iPod (Legacy)',          slug: 'ipod')
roots[:displays] = upsert_category!('Displays',               slug: 'displays')
roots[:network]  = upsert_category!('Networking (AirPort)',   slug: 'networking')
roots[:acc]      = upsert_category!('Accessories & Peripherals', slug: 'accessories')
roots[:vintage]  = upsert_category!('Vintage / Obsolete',     slug: 'vintage')

# Mac subtree
upsert_category!('MacBook',    slug: 'macbook',     parent: roots[:mac])
upsert_category!('iMac',       slug: 'imac',        parent: roots[:mac])
upsert_category!('Mac mini',   slug: 'mac-mini',    parent: roots[:mac])
upsert_category!('Mac Pro',    slug: 'mac-pro',     parent: roots[:mac])
upsert_category!('Mac Studio', slug: 'mac-studio',  parent: roots[:mac])

# Audio subtree
upsert_category!('AirPods',                  slug: 'airpods',    parent: roots[:audio])
upsert_category!('Speakers',                 slug: 'speakers',   parent: roots[:audio])
upsert_category!('Headphones & Earphones',   slug: 'headphones', parent: roots[:audio])

# TV & Home subtree
upsert_category!('Apple TV',   slug: 'apple-tv',   parent: roots[:tvhome])
upsert_category!('HomePod',    slug: 'homepod',    parent: roots[:tvhome])
upsert_category!('Vision Pro', slug: 'vision-pro', parent: roots[:tvhome])

# Displays subtree
upsert_category!('Studio Display',  slug: 'studio-display',   parent: roots[:displays])
upsert_category!('Pro Display XDR', slug: 'pro-display-xdr',  parent: roots[:displays])

# Accessories subtree
upsert_category!('Keyboards',        slug: 'keyboards',        parent: roots[:acc])
upsert_category!('Mice & Trackpads', slug: 'mice-trackpads',   parent: roots[:acc])
upsert_category!('Cables & Adapters',slug: 'cables-adapters',  parent: roots[:acc])
upsert_category!('Power & Charging', slug: 'power-charging',   parent: roots[:acc])
upsert_category!('Remotes',          slug: 'remotes',          parent: roots[:acc])

puts "[seeds] categories done"
