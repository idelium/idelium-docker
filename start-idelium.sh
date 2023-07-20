docker-compose -p idelium-demo up --build --detach
echo "building idelium fe"
docker exec -d idelium-demo-ideliumfe-1 sh -c "/tmp/build.sh"
echo "configure idelium api"
docker exec -d idelium-demo-ideliumapi-1 sh -c "/tmp/configure.sh"
echo "Open your browser to https://localhost"
