using CSV
using DataFrames
using Plots
data = CSV.read("file.csv", DataFrame)

# Filtrer les données selon la catégorie
function filter_data(df, category, value)
    return df[df[!, category] .== value, :]
end

# Nb de classes
function huntsbeerger_classes(n)
    return 1 + floor(Int, (10/3) * log(n))
end

function brooks_carruthers_classes(n)
    return floor(Int, 5 * log(n))
end


# Regroupement en classes par équidistance
function equidistant_classes(data_column, num_classes)
    min_val, max_val = minimum(data_column), maximum(data_column)
    step = (max_val - min_val) / num_classes
    bounds_matrix = Matrix{Float64}(undef, num_classes, 2)

    for i in 0:(num_classes - 1)
        bounds_matrix[i+1, 1] = min_val + step * i
        bounds_matrix[i+1, 2] = min_val + step * (i + 1)
    end

    return bounds_matrix
end

# regroupement par progression arithmétique
function arithmetic_classes(data_column, num_classes)
    min_val, max_val = minimum(data_column), maximum(data_column)
    total_range = sum(1:num_classes)
    R = (max_val - min_val) / total_range
    bounds_matrix = Matrix{Float64}(undef, num_classes, 2)

    for i in 0:(num_classes - 1)
        bounds_matrix[i+1, 1] = min_val + R * sum(1:i)
        bounds_matrix[i+1, 2] = min_val + R * sum(1:(i+1))
    end

    return bounds_matrix
end


# Compter combien d'individus sont dans la même classe
function group_data_into_classes(data_column, class_bounds)
    class_counts = zeros(Int, size(class_bounds, 1))
    for i in 1:size(class_bounds, 1)
        class_counts[i] = count(value -> class_bounds[i, 1] <= value < class_bounds[i, 2], data_column)
    end
    return class_counts
end


function plot_custom_histogram(class_counts, class_bounds, title::String)
    datax = String[]
    for i in 1:size(class_bounds, 1)
        push!(datax, string("[", round(class_bounds[i, 1], digits=1), ",", round(class_bounds[i, 2], digits=1), "]"))  
    end
    bar(datax, class_counts, legend=false, xrotation=30, xtickfontsize=8) # Note: j'ai pas réussi a afficher toute les "noms des classes" en abscisse sur le plot malgré le fait de baisser la police et orienter le texte
    xlabel!("Classes", fontsize=8)
    ylabel!("Nombre d'individus", fontsize=8)
    title!(title)
end

function plot_subplots(data) #nom a revoir
    n = size(data)[1]
    ages = data[!, :age]
    # Bornes des classes
    class_bounds_huntsbeerger_arithmetic = arithmetic_classes(ages, huntsbeerger_classes(n))
    class_bounds_brooks_arithmetic = arithmetic_classes(ages, brooks_carruthers_classes(n))
    class_bounds_huntsbeerger_equidistant = equidistant_classes(ages, huntsbeerger_classes(n))
    class_bounds_brooks_equidistant = equidistant_classes(ages, brooks_carruthers_classes(n))

    # Regrouper les données dans les classes

    class_counts_huntsbeerger_arithmetic = group_data_into_classes(ages, class_bounds_huntsbeerger_arithmetic)
    class_counts_brooks_arithmetic = group_data_into_classes(ages, class_bounds_brooks_arithmetic)
    class_counts_huntsbeerger_equidistant = group_data_into_classes(ages, class_bounds_huntsbeerger_equidistant)
    class_counts_brooks_equidistant = group_data_into_classes(ages, class_bounds_brooks_equidistant)

    # Tracer l'histogramme
    
    p1 = plot_custom_histogram(class_counts_huntsbeerger_arithmetic, class_bounds_huntsbeerger_arithmetic, "Méthode Huntsbeerger et Arithmetique")
    p2 = plot_custom_histogram(class_counts_brooks_arithmetic, class_bounds_brooks_arithmetic, "Méthode Brooks-Carruthers et Arithmetique")
    p3 = plot_custom_histogram(class_counts_huntsbeerger_equidistant, class_bounds_huntsbeerger_equidistant, "Méthode Huntsbeerger et Equidistante")
    p4 = plot_custom_histogram(class_counts_brooks_equidistant, class_bounds_brooks_equidistant, "Méthode Brooks-Carruthers et Equidistante")

    plot(p1, p2, p3, p4, size=(900,600))
end;


## Graphs

### répartition en classes d'âges pour tous les clients confondus
# plot_subplots(data)

### répartition en classes d'âges pour les ~~cadres~~ ouvriers ("blue-collar")
# filtres
# blue_collar_data = filter_data(data, :job, "blue-collar")
# plot_subplots(blue_collar_data)

### répartition en classes d'âges pour les personnes divorcées
# filtres
divorced_data = filter_data(data, :marital, "divorced")
plot_subplots(divorced_data)