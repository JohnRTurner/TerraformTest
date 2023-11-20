{
  echo "cat <<EOF>~/.env"
  echo "PGPASSWORD=$PGPASSWORD "
  echo "PGHOST=$PGHOST "
  echo "PGPORT=$PGHOST "
  echo "PGUSER=$PGUSER "
  echo "PGDATABASE=$PGDATABASE "
  echo "EOF"
} > out/pg_env.secret

cat out/pg_env.secret datagenerator.sh >> out/localbuild.sh