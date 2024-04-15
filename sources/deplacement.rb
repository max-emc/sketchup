require "sketchup"

class Animation

    def initialize
        # Définir les variables globales
        @model = Sketchup.active_model
        @entities = @model.active_entities
        @selection = @model.selection
        @fps = 60

        # Définir les propriétés des boutons
        buttons = [
            {"icon" => "trajectory_icon.png", "description" => "Ajouter une animation", "function" => method(:calculate_vectors)},
            {"icon" => "play_icon.png", "description" => "Jouer les animations", "function" => method(:move_objects)},
            {"icon" => "reload_icon.png", "description" => "Réinitialiser les animations", "function" => method(:reset_objects)},
        ]

        # Créer la barre d'outils
        toolbar = UI::Toolbar.new "Animations"

        # Créer chaque bouton
        buttons.each do |button|
            cmd = UI::Command.new("Toolbar Button") { button["function"].call }
            cmd.small_icon = join_paths(button["icon"])
            cmd.large_icon = join_paths(button["icon"])
            cmd.tooltip = button["description"]
            toolbar = toolbar.add_item cmd
        end

        toolbar.show
    end

    def join_paths(file)
        path = File.dirname(__FILE__)
        file_path = File.join(path, "deplacement", file)
    end

    def calculate_vectors

        # Vérifier si un composant est sélectionné
        if @selection.length == 1 || @selection.is_a?(Sketchup::ComponentInstance)
            object = @selection[0]
            @selection.remove(object)

            # Afficher la fenêtre html
            dialog = UI::HtmlDialog.new({
              :dialog_title => "Ajouter une animation",
              :width => 480,
              :height => 400,
              :style => UI::HtmlDialog::STYLE_DIALOG
            })

            dialog.set_file(join_paths("dialog.html"))

            dialog.add_action_callback("ruby_function") do |action_context, data_json|
                @selection = @model.selection

                if  @selection.length == 1 || @selection.is_a?(Sketchup::Edge)
                    
                    # Récupérer les données saisies
                    data = JSON.parse(data_json)
                    name = data["name"]
                    duration = Integer(data["duration"])
                    wait = Integer(data["wait"]) * @fps
                    steps = @fps * duration

                    # Renommer le composant
                    object.name = "$animation$ - #{name}"

                    # Calculer la trajectoire
                    trajectory = @selection[0]
                    start = trajectory.start.position
                    arrived = trajectory.end.position

                    distance_x = arrived.x - start.x
                    distance_y = arrived.y - start.y
                    distance_z = arrived.z - start.z

                    # Calculer le déplacement à chaque étape
                    translation_x = distance_x / steps
                    translation_y = distance_y / steps
                    translation_z = distance_z / steps

                    # Créer le vecteur
                    vector = Geom::Vector3d.new(translation_x, translation_y, translation_z)

                    # Ajouter les attributs au composant
                    object.set_attribute("animation", "steps", steps) 
                    object.set_attribute("animation", "wait", wait) 
                    object.set_attribute("animation", "start", object.transformation.origin) 
                    object.set_attribute("animation", "vector", vector) 
                    
                    UI.messagebox("La trajectoire a était ajoutée")
                    dialog.close
                else
                    UI.messagebox("Veuillez sélectionner une ligne")
                end
            end
            dialog.show
        else
            UI.messagebox("Veuillez sélectionner un composant")
        end
    end

    def move_objects
        @entities.each do |entity|
            if entity.is_a?(Sketchup::ComponentInstance) 
                if entity.name.include?("$animation$")

                    # Récupérer les attributs du composant
                    steps = entity.get_attribute("animation", "steps")
                    start = entity.get_attribute("animation", "start")

                    # Appliquer la transformation si le composant est à la position de départ
                    if entity.transformation.origin == start
                        wait = entity.get_attribute("animation", "wait")
                        vector = entity.get_attribute("animation", "vector")
                        translation = Geom::Transformation.translation(vector)

                        # Ajouter un timer pour respecter le nombre de fps
                        i = 1
                        timer = UI.start_timer(1 / @fps, true) {
                            if i > wait
                                entity.transform!(translation)
                            end
                            i += 1

                            if i > steps
                                UI.stop_timer(timer)
                                puts "fin"
                            end
                        }
                    end
                end
            end
        end
    end

    def reset_objects
        @entities.each do |entity|
            if entity.is_a?(Sketchup::ComponentInstance)        
                if entity.name.include?("$animation$")

                    # Vérifier si le composant n'est pas à la position de départ
                    start = entity.get_attribute("animation", "start")
                    if entity.transformation.origin != start

                        # Calculer les translations
                        translation_x = start.x - entity.transformation.origin.x 
                        translation_y = start.y - entity.transformation.origin.y 
                        translation_z = start.z - entity.transformation.origin.z

                        # Appliquer le vecteur pour rétablir la position initiale
                        reset_vector = Geom::Vector3d.new(translation_x, translation_y, translation_z)
                        reset_translation = Geom::Transformation.translation(reset_vector)
                        entity.transform!(reset_translation)
                    end
                end
            end
        end 
    end
end

Animation.new
