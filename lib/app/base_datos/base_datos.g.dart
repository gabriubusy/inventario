// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_datos.dart';

// ignore_for_file: type=lint
class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, FilaProducto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreClaveMeta = const VerificationMeta(
    'nombreClave',
  );
  @override
  late final GeneratedColumn<String> nombreClave = GeneratedColumn<String>(
    'nombre_clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Categoria, String> categoria =
      GeneratedColumn<String>(
        'categoria',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Categoria>($ProductosTable.$convertercategoria);
  @override
  late final GeneratedColumnWithTypeConverter<FormaConteo, String> forma =
      GeneratedColumn<String>(
        'forma',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FormaConteo>($ProductosTable.$converterforma);
  static const VerificationMeta _minimoMeta = const VerificationMeta('minimo');
  @override
  late final GeneratedColumn<int> minimo = GeneratedColumn<int>(
    'minimo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagenIdMeta = const VerificationMeta(
    'imagenId',
  );
  @override
  late final GeneratedColumn<String> imagenId = GeneratedColumn<String>(
    'imagen_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    nombreClave,
    categoria,
    forma,
    minimo,
    imagenId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaProducto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('nombre_clave')) {
      context.handle(
        _nombreClaveMeta,
        nombreClave.isAcceptableOrUnknown(
          data['nombre_clave']!,
          _nombreClaveMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreClaveMeta);
    }
    if (data.containsKey('minimo')) {
      context.handle(
        _minimoMeta,
        minimo.isAcceptableOrUnknown(data['minimo']!, _minimoMeta),
      );
    } else if (isInserting) {
      context.missing(_minimoMeta);
    }
    if (data.containsKey('imagen_id')) {
      context.handle(
        _imagenIdMeta,
        imagenId.isAcceptableOrUnknown(data['imagen_id']!, _imagenIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaProducto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaProducto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      nombreClave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_clave'],
      )!,
      categoria: $ProductosTable.$convertercategoria.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}categoria'],
        )!,
      ),
      forma: $ProductosTable.$converterforma.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma'],
        )!,
      ),
      minimo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimo'],
      )!,
      imagenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imagen_id'],
      ),
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Categoria, String, String> $convertercategoria =
      const EnumNameConverter<Categoria>(Categoria.values);
  static JsonTypeConverter2<FormaConteo, String, String> $converterforma =
      const EnumNameConverter<FormaConteo>(FormaConteo.values);
}

class FilaProducto extends DataClass implements Insertable<FilaProducto> {
  final String id;
  final String nombre;

  /// Name without case or accents; unique, so two products can't clash.
  final String nombreClave;
  final Categoria categoria;
  final FormaConteo forma;
  final int minimo;
  final String? imagenId;
  const FilaProducto({
    required this.id,
    required this.nombre,
    required this.nombreClave,
    required this.categoria,
    required this.forma,
    required this.minimo,
    this.imagenId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['nombre_clave'] = Variable<String>(nombreClave);
    {
      map['categoria'] = Variable<String>(
        $ProductosTable.$convertercategoria.toSql(categoria),
      );
    }
    {
      map['forma'] = Variable<String>(
        $ProductosTable.$converterforma.toSql(forma),
      );
    }
    map['minimo'] = Variable<int>(minimo);
    if (!nullToAbsent || imagenId != null) {
      map['imagen_id'] = Variable<String>(imagenId);
    }
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      nombreClave: Value(nombreClave),
      categoria: Value(categoria),
      forma: Value(forma),
      minimo: Value(minimo),
      imagenId: imagenId == null && nullToAbsent
          ? const Value.absent()
          : Value(imagenId),
    );
  }

  factory FilaProducto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaProducto(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      nombreClave: serializer.fromJson<String>(json['nombreClave']),
      categoria: $ProductosTable.$convertercategoria.fromJson(
        serializer.fromJson<String>(json['categoria']),
      ),
      forma: $ProductosTable.$converterforma.fromJson(
        serializer.fromJson<String>(json['forma']),
      ),
      minimo: serializer.fromJson<int>(json['minimo']),
      imagenId: serializer.fromJson<String?>(json['imagenId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'nombreClave': serializer.toJson<String>(nombreClave),
      'categoria': serializer.toJson<String>(
        $ProductosTable.$convertercategoria.toJson(categoria),
      ),
      'forma': serializer.toJson<String>(
        $ProductosTable.$converterforma.toJson(forma),
      ),
      'minimo': serializer.toJson<int>(minimo),
      'imagenId': serializer.toJson<String?>(imagenId),
    };
  }

  FilaProducto copyWith({
    String? id,
    String? nombre,
    String? nombreClave,
    Categoria? categoria,
    FormaConteo? forma,
    int? minimo,
    Value<String?> imagenId = const Value.absent(),
  }) => FilaProducto(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    nombreClave: nombreClave ?? this.nombreClave,
    categoria: categoria ?? this.categoria,
    forma: forma ?? this.forma,
    minimo: minimo ?? this.minimo,
    imagenId: imagenId.present ? imagenId.value : this.imagenId,
  );
  FilaProducto copyWithCompanion(ProductosCompanion data) {
    return FilaProducto(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      nombreClave: data.nombreClave.present
          ? data.nombreClave.value
          : this.nombreClave,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      forma: data.forma.present ? data.forma.value : this.forma,
      minimo: data.minimo.present ? data.minimo.value : this.minimo,
      imagenId: data.imagenId.present ? data.imagenId.value : this.imagenId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaProducto(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('nombreClave: $nombreClave, ')
          ..write('categoria: $categoria, ')
          ..write('forma: $forma, ')
          ..write('minimo: $minimo, ')
          ..write('imagenId: $imagenId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, nombreClave, categoria, forma, minimo, imagenId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaProducto &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.nombreClave == this.nombreClave &&
          other.categoria == this.categoria &&
          other.forma == this.forma &&
          other.minimo == this.minimo &&
          other.imagenId == this.imagenId);
}

class ProductosCompanion extends UpdateCompanion<FilaProducto> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> nombreClave;
  final Value<Categoria> categoria;
  final Value<FormaConteo> forma;
  final Value<int> minimo;
  final Value<String?> imagenId;
  final Value<int> rowid;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.nombreClave = const Value.absent(),
    this.categoria = const Value.absent(),
    this.forma = const Value.absent(),
    this.minimo = const Value.absent(),
    this.imagenId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosCompanion.insert({
    required String id,
    required String nombre,
    required String nombreClave,
    required Categoria categoria,
    required FormaConteo forma,
    required int minimo,
    this.imagenId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       nombreClave = Value(nombreClave),
       categoria = Value(categoria),
       forma = Value(forma),
       minimo = Value(minimo);
  static Insertable<FilaProducto> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? nombreClave,
    Expression<String>? categoria,
    Expression<String>? forma,
    Expression<int>? minimo,
    Expression<String>? imagenId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (nombreClave != null) 'nombre_clave': nombreClave,
      if (categoria != null) 'categoria': categoria,
      if (forma != null) 'forma': forma,
      if (minimo != null) 'minimo': minimo,
      if (imagenId != null) 'imagen_id': imagenId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String>? nombreClave,
    Value<Categoria>? categoria,
    Value<FormaConteo>? forma,
    Value<int>? minimo,
    Value<String?>? imagenId,
    Value<int>? rowid,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nombreClave: nombreClave ?? this.nombreClave,
      categoria: categoria ?? this.categoria,
      forma: forma ?? this.forma,
      minimo: minimo ?? this.minimo,
      imagenId: imagenId ?? this.imagenId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (nombreClave.present) {
      map['nombre_clave'] = Variable<String>(nombreClave.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(
        $ProductosTable.$convertercategoria.toSql(categoria.value),
      );
    }
    if (forma.present) {
      map['forma'] = Variable<String>(
        $ProductosTable.$converterforma.toSql(forma.value),
      );
    }
    if (minimo.present) {
      map['minimo'] = Variable<int>(minimo.value);
    }
    if (imagenId.present) {
      map['imagen_id'] = Variable<String>(imagenId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('nombreClave: $nombreClave, ')
          ..write('categoria: $categoria, ')
          ..write('forma: $forma, ')
          ..write('minimo: $minimo, ')
          ..write('imagenId: $imagenId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotesMarcaTable extends LotesMarca
    with TableInfo<$LotesMarcaTable, FilaLoteMarca> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesMarcaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piezasMeta = const VerificationMeta('piezas');
  @override
  late final GeneratedColumn<int> piezas = GeneratedColumn<int>(
    'piezas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piezaAbiertaMeta = const VerificationMeta(
    'piezaAbierta',
  );
  @override
  late final GeneratedColumn<bool> piezaAbierta = GeneratedColumn<bool>(
    'pieza_abierta',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pieza_abierta" IN (0, 1))',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<int> precio = GeneratedColumn<int>(
    'precio',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<int> costo = GeneratedColumn<int>(
    'costo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    productoId,
    orden,
    marca,
    proveedor,
    piezas,
    piezaAbierta,
    cantidad,
    precio,
    costo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes_marca';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaLoteMarca> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    } else if (isInserting) {
      context.missing(_marcaMeta);
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    } else if (isInserting) {
      context.missing(_proveedorMeta);
    }
    if (data.containsKey('piezas')) {
      context.handle(
        _piezasMeta,
        piezas.isAcceptableOrUnknown(data['piezas']!, _piezasMeta),
      );
    } else if (isInserting) {
      context.missing(_piezasMeta);
    }
    if (data.containsKey('pieza_abierta')) {
      context.handle(
        _piezaAbiertaMeta,
        piezaAbierta.isAcceptableOrUnknown(
          data['pieza_abierta']!,
          _piezaAbiertaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_piezaAbiertaMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(
        _precioMeta,
        precio.isAcceptableOrUnknown(data['precio']!, _precioMeta),
      );
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productoId, orden};
  @override
  FilaLoteMarca map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaLoteMarca(
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      )!,
      piezas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}piezas'],
      )!,
      piezaAbierta: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pieza_abierta'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio'],
      ),
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo'],
      ),
    );
  }

  @override
  $LotesMarcaTable createAlias(String alias) {
    return $LotesMarcaTable(attachedDatabase, alias);
  }
}

class FilaLoteMarca extends DataClass implements Insertable<FilaLoteMarca> {
  final String productoId;

  /// Keeps the brands in the order the user typed them.
  final int orden;
  final String marca;
  final String proveedor;
  final int piezas;
  final bool piezaAbierta;
  final int cantidad;
  final int? precio;
  final int? costo;
  const FilaLoteMarca({
    required this.productoId,
    required this.orden,
    required this.marca,
    required this.proveedor,
    required this.piezas,
    required this.piezaAbierta,
    required this.cantidad,
    this.precio,
    this.costo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['producto_id'] = Variable<String>(productoId);
    map['orden'] = Variable<int>(orden);
    map['marca'] = Variable<String>(marca);
    map['proveedor'] = Variable<String>(proveedor);
    map['piezas'] = Variable<int>(piezas);
    map['pieza_abierta'] = Variable<bool>(piezaAbierta);
    map['cantidad'] = Variable<int>(cantidad);
    if (!nullToAbsent || precio != null) {
      map['precio'] = Variable<int>(precio);
    }
    if (!nullToAbsent || costo != null) {
      map['costo'] = Variable<int>(costo);
    }
    return map;
  }

  LotesMarcaCompanion toCompanion(bool nullToAbsent) {
    return LotesMarcaCompanion(
      productoId: Value(productoId),
      orden: Value(orden),
      marca: Value(marca),
      proveedor: Value(proveedor),
      piezas: Value(piezas),
      piezaAbierta: Value(piezaAbierta),
      cantidad: Value(cantidad),
      precio: precio == null && nullToAbsent
          ? const Value.absent()
          : Value(precio),
      costo: costo == null && nullToAbsent
          ? const Value.absent()
          : Value(costo),
    );
  }

  factory FilaLoteMarca.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaLoteMarca(
      productoId: serializer.fromJson<String>(json['productoId']),
      orden: serializer.fromJson<int>(json['orden']),
      marca: serializer.fromJson<String>(json['marca']),
      proveedor: serializer.fromJson<String>(json['proveedor']),
      piezas: serializer.fromJson<int>(json['piezas']),
      piezaAbierta: serializer.fromJson<bool>(json['piezaAbierta']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precio: serializer.fromJson<int?>(json['precio']),
      costo: serializer.fromJson<int?>(json['costo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productoId': serializer.toJson<String>(productoId),
      'orden': serializer.toJson<int>(orden),
      'marca': serializer.toJson<String>(marca),
      'proveedor': serializer.toJson<String>(proveedor),
      'piezas': serializer.toJson<int>(piezas),
      'piezaAbierta': serializer.toJson<bool>(piezaAbierta),
      'cantidad': serializer.toJson<int>(cantidad),
      'precio': serializer.toJson<int?>(precio),
      'costo': serializer.toJson<int?>(costo),
    };
  }

  FilaLoteMarca copyWith({
    String? productoId,
    int? orden,
    String? marca,
    String? proveedor,
    int? piezas,
    bool? piezaAbierta,
    int? cantidad,
    Value<int?> precio = const Value.absent(),
    Value<int?> costo = const Value.absent(),
  }) => FilaLoteMarca(
    productoId: productoId ?? this.productoId,
    orden: orden ?? this.orden,
    marca: marca ?? this.marca,
    proveedor: proveedor ?? this.proveedor,
    piezas: piezas ?? this.piezas,
    piezaAbierta: piezaAbierta ?? this.piezaAbierta,
    cantidad: cantidad ?? this.cantidad,
    precio: precio.present ? precio.value : this.precio,
    costo: costo.present ? costo.value : this.costo,
  );
  FilaLoteMarca copyWithCompanion(LotesMarcaCompanion data) {
    return FilaLoteMarca(
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      orden: data.orden.present ? data.orden.value : this.orden,
      marca: data.marca.present ? data.marca.value : this.marca,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      piezas: data.piezas.present ? data.piezas.value : this.piezas,
      piezaAbierta: data.piezaAbierta.present
          ? data.piezaAbierta.value
          : this.piezaAbierta,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precio: data.precio.present ? data.precio.value : this.precio,
      costo: data.costo.present ? data.costo.value : this.costo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaLoteMarca(')
          ..write('productoId: $productoId, ')
          ..write('orden: $orden, ')
          ..write('marca: $marca, ')
          ..write('proveedor: $proveedor, ')
          ..write('piezas: $piezas, ')
          ..write('piezaAbierta: $piezaAbierta, ')
          ..write('cantidad: $cantidad, ')
          ..write('precio: $precio, ')
          ..write('costo: $costo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    productoId,
    orden,
    marca,
    proveedor,
    piezas,
    piezaAbierta,
    cantidad,
    precio,
    costo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaLoteMarca &&
          other.productoId == this.productoId &&
          other.orden == this.orden &&
          other.marca == this.marca &&
          other.proveedor == this.proveedor &&
          other.piezas == this.piezas &&
          other.piezaAbierta == this.piezaAbierta &&
          other.cantidad == this.cantidad &&
          other.precio == this.precio &&
          other.costo == this.costo);
}

class LotesMarcaCompanion extends UpdateCompanion<FilaLoteMarca> {
  final Value<String> productoId;
  final Value<int> orden;
  final Value<String> marca;
  final Value<String> proveedor;
  final Value<int> piezas;
  final Value<bool> piezaAbierta;
  final Value<int> cantidad;
  final Value<int?> precio;
  final Value<int?> costo;
  final Value<int> rowid;
  const LotesMarcaCompanion({
    this.productoId = const Value.absent(),
    this.orden = const Value.absent(),
    this.marca = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.piezas = const Value.absent(),
    this.piezaAbierta = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precio = const Value.absent(),
    this.costo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotesMarcaCompanion.insert({
    required String productoId,
    required int orden,
    required String marca,
    required String proveedor,
    required int piezas,
    required bool piezaAbierta,
    required int cantidad,
    this.precio = const Value.absent(),
    this.costo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productoId = Value(productoId),
       orden = Value(orden),
       marca = Value(marca),
       proveedor = Value(proveedor),
       piezas = Value(piezas),
       piezaAbierta = Value(piezaAbierta),
       cantidad = Value(cantidad);
  static Insertable<FilaLoteMarca> custom({
    Expression<String>? productoId,
    Expression<int>? orden,
    Expression<String>? marca,
    Expression<String>? proveedor,
    Expression<int>? piezas,
    Expression<bool>? piezaAbierta,
    Expression<int>? cantidad,
    Expression<int>? precio,
    Expression<int>? costo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productoId != null) 'producto_id': productoId,
      if (orden != null) 'orden': orden,
      if (marca != null) 'marca': marca,
      if (proveedor != null) 'proveedor': proveedor,
      if (piezas != null) 'piezas': piezas,
      if (piezaAbierta != null) 'pieza_abierta': piezaAbierta,
      if (cantidad != null) 'cantidad': cantidad,
      if (precio != null) 'precio': precio,
      if (costo != null) 'costo': costo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotesMarcaCompanion copyWith({
    Value<String>? productoId,
    Value<int>? orden,
    Value<String>? marca,
    Value<String>? proveedor,
    Value<int>? piezas,
    Value<bool>? piezaAbierta,
    Value<int>? cantidad,
    Value<int?>? precio,
    Value<int?>? costo,
    Value<int>? rowid,
  }) {
    return LotesMarcaCompanion(
      productoId: productoId ?? this.productoId,
      orden: orden ?? this.orden,
      marca: marca ?? this.marca,
      proveedor: proveedor ?? this.proveedor,
      piezas: piezas ?? this.piezas,
      piezaAbierta: piezaAbierta ?? this.piezaAbierta,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      costo: costo ?? this.costo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (piezas.present) {
      map['piezas'] = Variable<int>(piezas.value);
    }
    if (piezaAbierta.present) {
      map['pieza_abierta'] = Variable<bool>(piezaAbierta.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precio.present) {
      map['precio'] = Variable<int>(precio.value);
    }
    if (costo.present) {
      map['costo'] = Variable<int>(costo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesMarcaCompanion(')
          ..write('productoId: $productoId, ')
          ..write('orden: $orden, ')
          ..write('marca: $marca, ')
          ..write('proveedor: $proveedor, ')
          ..write('piezas: $piezas, ')
          ..write('piezaAbierta: $piezaAbierta, ')
          ..write('cantidad: $cantidad, ')
          ..write('precio: $precio, ')
          ..write('costo: $costo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PresentacionesTable extends Presentaciones
    with TableInfo<$PresentacionesTable, FilaPresentacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresentacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factorMeta = const VerificationMeta('factor');
  @override
  late final GeneratedColumn<int> factor = GeneratedColumn<int>(
    'factor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioMeta = const VerificationMeta('precio');
  @override
  late final GeneratedColumn<int> precio = GeneratedColumn<int>(
    'precio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predeterminadaMeta = const VerificationMeta(
    'predeterminada',
  );
  @override
  late final GeneratedColumn<bool> predeterminada = GeneratedColumn<bool>(
    'predeterminada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("predeterminada" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    productoId,
    orden,
    nombre,
    factor,
    precio,
    codigo,
    predeterminada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presentaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaPresentacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('factor')) {
      context.handle(
        _factorMeta,
        factor.isAcceptableOrUnknown(data['factor']!, _factorMeta),
      );
    } else if (isInserting) {
      context.missing(_factorMeta);
    }
    if (data.containsKey('precio')) {
      context.handle(
        _precioMeta,
        precio.isAcceptableOrUnknown(data['precio']!, _precioMeta),
      );
    } else if (isInserting) {
      context.missing(_precioMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('predeterminada')) {
      context.handle(
        _predeterminadaMeta,
        predeterminada.isAcceptableOrUnknown(
          data['predeterminada']!,
          _predeterminadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predeterminadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productoId, orden};
  @override
  FilaPresentacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaPresentacion(
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      factor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}factor'],
      )!,
      precio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      predeterminada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}predeterminada'],
      )!,
    );
  }

  @override
  $PresentacionesTable createAlias(String alias) {
    return $PresentacionesTable(attachedDatabase, alias);
  }
}

class FilaPresentacion extends DataClass
    implements Insertable<FilaPresentacion> {
  final String productoId;
  final int orden;
  final String nombre;
  final int factor;
  final int precio;
  final String codigo;
  final bool predeterminada;
  const FilaPresentacion({
    required this.productoId,
    required this.orden,
    required this.nombre,
    required this.factor,
    required this.precio,
    required this.codigo,
    required this.predeterminada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['producto_id'] = Variable<String>(productoId);
    map['orden'] = Variable<int>(orden);
    map['nombre'] = Variable<String>(nombre);
    map['factor'] = Variable<int>(factor);
    map['precio'] = Variable<int>(precio);
    map['codigo'] = Variable<String>(codigo);
    map['predeterminada'] = Variable<bool>(predeterminada);
    return map;
  }

  PresentacionesCompanion toCompanion(bool nullToAbsent) {
    return PresentacionesCompanion(
      productoId: Value(productoId),
      orden: Value(orden),
      nombre: Value(nombre),
      factor: Value(factor),
      precio: Value(precio),
      codigo: Value(codigo),
      predeterminada: Value(predeterminada),
    );
  }

  factory FilaPresentacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaPresentacion(
      productoId: serializer.fromJson<String>(json['productoId']),
      orden: serializer.fromJson<int>(json['orden']),
      nombre: serializer.fromJson<String>(json['nombre']),
      factor: serializer.fromJson<int>(json['factor']),
      precio: serializer.fromJson<int>(json['precio']),
      codigo: serializer.fromJson<String>(json['codigo']),
      predeterminada: serializer.fromJson<bool>(json['predeterminada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productoId': serializer.toJson<String>(productoId),
      'orden': serializer.toJson<int>(orden),
      'nombre': serializer.toJson<String>(nombre),
      'factor': serializer.toJson<int>(factor),
      'precio': serializer.toJson<int>(precio),
      'codigo': serializer.toJson<String>(codigo),
      'predeterminada': serializer.toJson<bool>(predeterminada),
    };
  }

  FilaPresentacion copyWith({
    String? productoId,
    int? orden,
    String? nombre,
    int? factor,
    int? precio,
    String? codigo,
    bool? predeterminada,
  }) => FilaPresentacion(
    productoId: productoId ?? this.productoId,
    orden: orden ?? this.orden,
    nombre: nombre ?? this.nombre,
    factor: factor ?? this.factor,
    precio: precio ?? this.precio,
    codigo: codigo ?? this.codigo,
    predeterminada: predeterminada ?? this.predeterminada,
  );
  FilaPresentacion copyWithCompanion(PresentacionesCompanion data) {
    return FilaPresentacion(
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      orden: data.orden.present ? data.orden.value : this.orden,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      factor: data.factor.present ? data.factor.value : this.factor,
      precio: data.precio.present ? data.precio.value : this.precio,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      predeterminada: data.predeterminada.present
          ? data.predeterminada.value
          : this.predeterminada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaPresentacion(')
          ..write('productoId: $productoId, ')
          ..write('orden: $orden, ')
          ..write('nombre: $nombre, ')
          ..write('factor: $factor, ')
          ..write('precio: $precio, ')
          ..write('codigo: $codigo, ')
          ..write('predeterminada: $predeterminada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    productoId,
    orden,
    nombre,
    factor,
    precio,
    codigo,
    predeterminada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaPresentacion &&
          other.productoId == this.productoId &&
          other.orden == this.orden &&
          other.nombre == this.nombre &&
          other.factor == this.factor &&
          other.precio == this.precio &&
          other.codigo == this.codigo &&
          other.predeterminada == this.predeterminada);
}

class PresentacionesCompanion extends UpdateCompanion<FilaPresentacion> {
  final Value<String> productoId;
  final Value<int> orden;
  final Value<String> nombre;
  final Value<int> factor;
  final Value<int> precio;
  final Value<String> codigo;
  final Value<bool> predeterminada;
  final Value<int> rowid;
  const PresentacionesCompanion({
    this.productoId = const Value.absent(),
    this.orden = const Value.absent(),
    this.nombre = const Value.absent(),
    this.factor = const Value.absent(),
    this.precio = const Value.absent(),
    this.codigo = const Value.absent(),
    this.predeterminada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PresentacionesCompanion.insert({
    required String productoId,
    required int orden,
    required String nombre,
    required int factor,
    required int precio,
    required String codigo,
    required bool predeterminada,
    this.rowid = const Value.absent(),
  }) : productoId = Value(productoId),
       orden = Value(orden),
       nombre = Value(nombre),
       factor = Value(factor),
       precio = Value(precio),
       codigo = Value(codigo),
       predeterminada = Value(predeterminada);
  static Insertable<FilaPresentacion> custom({
    Expression<String>? productoId,
    Expression<int>? orden,
    Expression<String>? nombre,
    Expression<int>? factor,
    Expression<int>? precio,
    Expression<String>? codigo,
    Expression<bool>? predeterminada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productoId != null) 'producto_id': productoId,
      if (orden != null) 'orden': orden,
      if (nombre != null) 'nombre': nombre,
      if (factor != null) 'factor': factor,
      if (precio != null) 'precio': precio,
      if (codigo != null) 'codigo': codigo,
      if (predeterminada != null) 'predeterminada': predeterminada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PresentacionesCompanion copyWith({
    Value<String>? productoId,
    Value<int>? orden,
    Value<String>? nombre,
    Value<int>? factor,
    Value<int>? precio,
    Value<String>? codigo,
    Value<bool>? predeterminada,
    Value<int>? rowid,
  }) {
    return PresentacionesCompanion(
      productoId: productoId ?? this.productoId,
      orden: orden ?? this.orden,
      nombre: nombre ?? this.nombre,
      factor: factor ?? this.factor,
      precio: precio ?? this.precio,
      codigo: codigo ?? this.codigo,
      predeterminada: predeterminada ?? this.predeterminada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (factor.present) {
      map['factor'] = Variable<int>(factor.value);
    }
    if (precio.present) {
      map['precio'] = Variable<int>(precio.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (predeterminada.present) {
      map['predeterminada'] = Variable<bool>(predeterminada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresentacionesCompanion(')
          ..write('productoId: $productoId, ')
          ..write('orden: $orden, ')
          ..write('nombre: $nombre, ')
          ..write('factor: $factor, ')
          ..write('precio: $precio, ')
          ..write('codigo: $codigo, ')
          ..write('predeterminada: $predeterminada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProveedoresTable extends Proveedores
    with TableInfo<$ProveedoresTable, FilaProveedor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProveedoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreClaveMeta = const VerificationMeta(
    'nombreClave',
  );
  @override
  late final GeneratedColumn<String> nombreClave = GeneratedColumn<String>(
    'nombre_clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _rifMeta = const VerificationMeta('rif');
  @override
  late final GeneratedColumn<String> rif = GeneratedColumn<String>(
    'rif',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactoMeta = const VerificationMeta(
    'contacto',
  );
  @override
  late final GeneratedColumn<String> contacto = GeneratedColumn<String>(
    'contacto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    nombreClave,
    rif,
    telefono,
    contacto,
    notas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proveedores';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaProveedor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('nombre_clave')) {
      context.handle(
        _nombreClaveMeta,
        nombreClave.isAcceptableOrUnknown(
          data['nombre_clave']!,
          _nombreClaveMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreClaveMeta);
    }
    if (data.containsKey('rif')) {
      context.handle(
        _rifMeta,
        rif.isAcceptableOrUnknown(data['rif']!, _rifMeta),
      );
    } else if (isInserting) {
      context.missing(_rifMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    } else if (isInserting) {
      context.missing(_telefonoMeta);
    }
    if (data.containsKey('contacto')) {
      context.handle(
        _contactoMeta,
        contacto.isAcceptableOrUnknown(data['contacto']!, _contactoMeta),
      );
    } else if (isInserting) {
      context.missing(_contactoMeta);
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    } else if (isInserting) {
      context.missing(_notasMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaProveedor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaProveedor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      nombreClave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_clave'],
      )!,
      rif: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rif'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      )!,
      contacto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contacto'],
      )!,
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      )!,
    );
  }

  @override
  $ProveedoresTable createAlias(String alias) {
    return $ProveedoresTable(attachedDatabase, alias);
  }
}

class FilaProveedor extends DataClass implements Insertable<FilaProveedor> {
  final String id;
  final String nombre;

  /// Name without case or accents; unique like the product's.
  final String nombreClave;
  final String rif;
  final String telefono;
  final String contacto;
  final String notas;
  const FilaProveedor({
    required this.id,
    required this.nombre,
    required this.nombreClave,
    required this.rif,
    required this.telefono,
    required this.contacto,
    required this.notas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['nombre_clave'] = Variable<String>(nombreClave);
    map['rif'] = Variable<String>(rif);
    map['telefono'] = Variable<String>(telefono);
    map['contacto'] = Variable<String>(contacto);
    map['notas'] = Variable<String>(notas);
    return map;
  }

  ProveedoresCompanion toCompanion(bool nullToAbsent) {
    return ProveedoresCompanion(
      id: Value(id),
      nombre: Value(nombre),
      nombreClave: Value(nombreClave),
      rif: Value(rif),
      telefono: Value(telefono),
      contacto: Value(contacto),
      notas: Value(notas),
    );
  }

  factory FilaProveedor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaProveedor(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      nombreClave: serializer.fromJson<String>(json['nombreClave']),
      rif: serializer.fromJson<String>(json['rif']),
      telefono: serializer.fromJson<String>(json['telefono']),
      contacto: serializer.fromJson<String>(json['contacto']),
      notas: serializer.fromJson<String>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'nombreClave': serializer.toJson<String>(nombreClave),
      'rif': serializer.toJson<String>(rif),
      'telefono': serializer.toJson<String>(telefono),
      'contacto': serializer.toJson<String>(contacto),
      'notas': serializer.toJson<String>(notas),
    };
  }

  FilaProveedor copyWith({
    String? id,
    String? nombre,
    String? nombreClave,
    String? rif,
    String? telefono,
    String? contacto,
    String? notas,
  }) => FilaProveedor(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    nombreClave: nombreClave ?? this.nombreClave,
    rif: rif ?? this.rif,
    telefono: telefono ?? this.telefono,
    contacto: contacto ?? this.contacto,
    notas: notas ?? this.notas,
  );
  FilaProveedor copyWithCompanion(ProveedoresCompanion data) {
    return FilaProveedor(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      nombreClave: data.nombreClave.present
          ? data.nombreClave.value
          : this.nombreClave,
      rif: data.rif.present ? data.rif.value : this.rif,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      contacto: data.contacto.present ? data.contacto.value : this.contacto,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaProveedor(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('nombreClave: $nombreClave, ')
          ..write('rif: $rif, ')
          ..write('telefono: $telefono, ')
          ..write('contacto: $contacto, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, nombreClave, rif, telefono, contacto, notas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaProveedor &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.nombreClave == this.nombreClave &&
          other.rif == this.rif &&
          other.telefono == this.telefono &&
          other.contacto == this.contacto &&
          other.notas == this.notas);
}

class ProveedoresCompanion extends UpdateCompanion<FilaProveedor> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> nombreClave;
  final Value<String> rif;
  final Value<String> telefono;
  final Value<String> contacto;
  final Value<String> notas;
  final Value<int> rowid;
  const ProveedoresCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.nombreClave = const Value.absent(),
    this.rif = const Value.absent(),
    this.telefono = const Value.absent(),
    this.contacto = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProveedoresCompanion.insert({
    required String id,
    required String nombre,
    required String nombreClave,
    required String rif,
    required String telefono,
    required String contacto,
    required String notas,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       nombreClave = Value(nombreClave),
       rif = Value(rif),
       telefono = Value(telefono),
       contacto = Value(contacto),
       notas = Value(notas);
  static Insertable<FilaProveedor> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? nombreClave,
    Expression<String>? rif,
    Expression<String>? telefono,
    Expression<String>? contacto,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (nombreClave != null) 'nombre_clave': nombreClave,
      if (rif != null) 'rif': rif,
      if (telefono != null) 'telefono': telefono,
      if (contacto != null) 'contacto': contacto,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProveedoresCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String>? nombreClave,
    Value<String>? rif,
    Value<String>? telefono,
    Value<String>? contacto,
    Value<String>? notas,
    Value<int>? rowid,
  }) {
    return ProveedoresCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nombreClave: nombreClave ?? this.nombreClave,
      rif: rif ?? this.rif,
      telefono: telefono ?? this.telefono,
      contacto: contacto ?? this.contacto,
      notas: notas ?? this.notas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (nombreClave.present) {
      map['nombre_clave'] = Variable<String>(nombreClave.value);
    }
    if (rif.present) {
      map['rif'] = Variable<String>(rif.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (contacto.present) {
      map['contacto'] = Variable<String>(contacto.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProveedoresCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('nombreClave: $nombreClave, ')
          ..write('rif: $rif, ')
          ..write('telefono: $telefono, ')
          ..write('contacto: $contacto, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncidenciasTable extends Incidencias
    with TableInfo<$IncidenciasTable, FilaIncidencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncidenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FormaConteo, String> forma =
      GeneratedColumn<String>(
        'forma',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FormaConteo>($IncidenciasTable.$converterforma);
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoIncidencia, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoIncidencia>($IncidenciasTable.$convertertipo);
  static const VerificationMeta _piezasMeta = const VerificationMeta('piezas');
  @override
  late final GeneratedColumn<int> piezas = GeneratedColumn<int>(
    'piezas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sacadaMeta = const VerificationMeta('sacada');
  @override
  late final GeneratedColumn<bool> sacada = GeneratedColumn<bool>(
    'sacada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sacada" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RespuestaProveedor?, String>
  respuesta = GeneratedColumn<String>(
    'respuesta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<RespuestaProveedor?>($IncidenciasTable.$converterrespuestan);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    proveedor,
    productoId,
    producto,
    forma,
    marca,
    tipo,
    piezas,
    cantidad,
    nota,
    sacada,
    respuesta,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incidencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaIncidencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    } else if (isInserting) {
      context.missing(_proveedorMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    } else if (isInserting) {
      context.missing(_productoMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    } else if (isInserting) {
      context.missing(_marcaMeta);
    }
    if (data.containsKey('piezas')) {
      context.handle(
        _piezasMeta,
        piezas.isAcceptableOrUnknown(data['piezas']!, _piezasMeta),
      );
    } else if (isInserting) {
      context.missing(_piezasMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    } else if (isInserting) {
      context.missing(_notaMeta);
    }
    if (data.containsKey('sacada')) {
      context.handle(
        _sacadaMeta,
        sacada.isAcceptableOrUnknown(data['sacada']!, _sacadaMeta),
      );
    } else if (isInserting) {
      context.missing(_sacadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaIncidencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaIncidencia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      )!,
      forma: $IncidenciasTable.$converterforma.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma'],
        )!,
      ),
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      tipo: $IncidenciasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      piezas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}piezas'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      )!,
      sacada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sacada'],
      )!,
      respuesta: $IncidenciasTable.$converterrespuestan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}respuesta'],
        ),
      ),
    );
  }

  @override
  $IncidenciasTable createAlias(String alias) {
    return $IncidenciasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FormaConteo, String, String> $converterforma =
      const EnumNameConverter<FormaConteo>(FormaConteo.values);
  static JsonTypeConverter2<TipoIncidencia, String, String> $convertertipo =
      const EnumNameConverter<TipoIncidencia>(TipoIncidencia.values);
  static JsonTypeConverter2<RespuestaProveedor, String, String>
  $converterrespuesta = const EnumNameConverter<RespuestaProveedor>(
    RespuestaProveedor.values,
  );
  static JsonTypeConverter2<RespuestaProveedor?, String?, String?>
  $converterrespuestan = JsonTypeConverter2.asNullable($converterrespuesta);
}

class FilaIncidencia extends DataClass implements Insertable<FilaIncidencia> {
  final String id;
  final DateTime fecha;
  final String proveedor;
  final String productoId;
  final String producto;
  final FormaConteo forma;
  final String marca;
  final TipoIncidencia tipo;
  final int piezas;
  final int cantidad;
  final String nota;
  final bool sacada;
  final RespuestaProveedor? respuesta;
  const FilaIncidencia({
    required this.id,
    required this.fecha,
    required this.proveedor,
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    required this.tipo,
    required this.piezas,
    required this.cantidad,
    required this.nota,
    required this.sacada,
    this.respuesta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['proveedor'] = Variable<String>(proveedor);
    map['producto_id'] = Variable<String>(productoId);
    map['producto'] = Variable<String>(producto);
    {
      map['forma'] = Variable<String>(
        $IncidenciasTable.$converterforma.toSql(forma),
      );
    }
    map['marca'] = Variable<String>(marca);
    {
      map['tipo'] = Variable<String>(
        $IncidenciasTable.$convertertipo.toSql(tipo),
      );
    }
    map['piezas'] = Variable<int>(piezas);
    map['cantidad'] = Variable<int>(cantidad);
    map['nota'] = Variable<String>(nota);
    map['sacada'] = Variable<bool>(sacada);
    if (!nullToAbsent || respuesta != null) {
      map['respuesta'] = Variable<String>(
        $IncidenciasTable.$converterrespuestan.toSql(respuesta),
      );
    }
    return map;
  }

  IncidenciasCompanion toCompanion(bool nullToAbsent) {
    return IncidenciasCompanion(
      id: Value(id),
      fecha: Value(fecha),
      proveedor: Value(proveedor),
      productoId: Value(productoId),
      producto: Value(producto),
      forma: Value(forma),
      marca: Value(marca),
      tipo: Value(tipo),
      piezas: Value(piezas),
      cantidad: Value(cantidad),
      nota: Value(nota),
      sacada: Value(sacada),
      respuesta: respuesta == null && nullToAbsent
          ? const Value.absent()
          : Value(respuesta),
    );
  }

  factory FilaIncidencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaIncidencia(
      id: serializer.fromJson<String>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      proveedor: serializer.fromJson<String>(json['proveedor']),
      productoId: serializer.fromJson<String>(json['productoId']),
      producto: serializer.fromJson<String>(json['producto']),
      forma: $IncidenciasTable.$converterforma.fromJson(
        serializer.fromJson<String>(json['forma']),
      ),
      marca: serializer.fromJson<String>(json['marca']),
      tipo: $IncidenciasTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      piezas: serializer.fromJson<int>(json['piezas']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      nota: serializer.fromJson<String>(json['nota']),
      sacada: serializer.fromJson<bool>(json['sacada']),
      respuesta: $IncidenciasTable.$converterrespuestan.fromJson(
        serializer.fromJson<String?>(json['respuesta']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'proveedor': serializer.toJson<String>(proveedor),
      'productoId': serializer.toJson<String>(productoId),
      'producto': serializer.toJson<String>(producto),
      'forma': serializer.toJson<String>(
        $IncidenciasTable.$converterforma.toJson(forma),
      ),
      'marca': serializer.toJson<String>(marca),
      'tipo': serializer.toJson<String>(
        $IncidenciasTable.$convertertipo.toJson(tipo),
      ),
      'piezas': serializer.toJson<int>(piezas),
      'cantidad': serializer.toJson<int>(cantidad),
      'nota': serializer.toJson<String>(nota),
      'sacada': serializer.toJson<bool>(sacada),
      'respuesta': serializer.toJson<String?>(
        $IncidenciasTable.$converterrespuestan.toJson(respuesta),
      ),
    };
  }

  FilaIncidencia copyWith({
    String? id,
    DateTime? fecha,
    String? proveedor,
    String? productoId,
    String? producto,
    FormaConteo? forma,
    String? marca,
    TipoIncidencia? tipo,
    int? piezas,
    int? cantidad,
    String? nota,
    bool? sacada,
    Value<RespuestaProveedor?> respuesta = const Value.absent(),
  }) => FilaIncidencia(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    proveedor: proveedor ?? this.proveedor,
    productoId: productoId ?? this.productoId,
    producto: producto ?? this.producto,
    forma: forma ?? this.forma,
    marca: marca ?? this.marca,
    tipo: tipo ?? this.tipo,
    piezas: piezas ?? this.piezas,
    cantidad: cantidad ?? this.cantidad,
    nota: nota ?? this.nota,
    sacada: sacada ?? this.sacada,
    respuesta: respuesta.present ? respuesta.value : this.respuesta,
  );
  FilaIncidencia copyWithCompanion(IncidenciasCompanion data) {
    return FilaIncidencia(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      producto: data.producto.present ? data.producto.value : this.producto,
      forma: data.forma.present ? data.forma.value : this.forma,
      marca: data.marca.present ? data.marca.value : this.marca,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      piezas: data.piezas.present ? data.piezas.value : this.piezas,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      nota: data.nota.present ? data.nota.value : this.nota,
      sacada: data.sacada.present ? data.sacada.value : this.sacada,
      respuesta: data.respuesta.present ? data.respuesta.value : this.respuesta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaIncidencia(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('proveedor: $proveedor, ')
          ..write('productoId: $productoId, ')
          ..write('producto: $producto, ')
          ..write('forma: $forma, ')
          ..write('marca: $marca, ')
          ..write('tipo: $tipo, ')
          ..write('piezas: $piezas, ')
          ..write('cantidad: $cantidad, ')
          ..write('nota: $nota, ')
          ..write('sacada: $sacada, ')
          ..write('respuesta: $respuesta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    proveedor,
    productoId,
    producto,
    forma,
    marca,
    tipo,
    piezas,
    cantidad,
    nota,
    sacada,
    respuesta,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaIncidencia &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.proveedor == this.proveedor &&
          other.productoId == this.productoId &&
          other.producto == this.producto &&
          other.forma == this.forma &&
          other.marca == this.marca &&
          other.tipo == this.tipo &&
          other.piezas == this.piezas &&
          other.cantidad == this.cantidad &&
          other.nota == this.nota &&
          other.sacada == this.sacada &&
          other.respuesta == this.respuesta);
}

class IncidenciasCompanion extends UpdateCompanion<FilaIncidencia> {
  final Value<String> id;
  final Value<DateTime> fecha;
  final Value<String> proveedor;
  final Value<String> productoId;
  final Value<String> producto;
  final Value<FormaConteo> forma;
  final Value<String> marca;
  final Value<TipoIncidencia> tipo;
  final Value<int> piezas;
  final Value<int> cantidad;
  final Value<String> nota;
  final Value<bool> sacada;
  final Value<RespuestaProveedor?> respuesta;
  final Value<int> rowid;
  const IncidenciasCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.productoId = const Value.absent(),
    this.producto = const Value.absent(),
    this.forma = const Value.absent(),
    this.marca = const Value.absent(),
    this.tipo = const Value.absent(),
    this.piezas = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.nota = const Value.absent(),
    this.sacada = const Value.absent(),
    this.respuesta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncidenciasCompanion.insert({
    required String id,
    required DateTime fecha,
    required String proveedor,
    required String productoId,
    required String producto,
    required FormaConteo forma,
    required String marca,
    required TipoIncidencia tipo,
    required int piezas,
    required int cantidad,
    required String nota,
    required bool sacada,
    this.respuesta = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       proveedor = Value(proveedor),
       productoId = Value(productoId),
       producto = Value(producto),
       forma = Value(forma),
       marca = Value(marca),
       tipo = Value(tipo),
       piezas = Value(piezas),
       cantidad = Value(cantidad),
       nota = Value(nota),
       sacada = Value(sacada);
  static Insertable<FilaIncidencia> custom({
    Expression<String>? id,
    Expression<DateTime>? fecha,
    Expression<String>? proveedor,
    Expression<String>? productoId,
    Expression<String>? producto,
    Expression<String>? forma,
    Expression<String>? marca,
    Expression<String>? tipo,
    Expression<int>? piezas,
    Expression<int>? cantidad,
    Expression<String>? nota,
    Expression<bool>? sacada,
    Expression<String>? respuesta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (proveedor != null) 'proveedor': proveedor,
      if (productoId != null) 'producto_id': productoId,
      if (producto != null) 'producto': producto,
      if (forma != null) 'forma': forma,
      if (marca != null) 'marca': marca,
      if (tipo != null) 'tipo': tipo,
      if (piezas != null) 'piezas': piezas,
      if (cantidad != null) 'cantidad': cantidad,
      if (nota != null) 'nota': nota,
      if (sacada != null) 'sacada': sacada,
      if (respuesta != null) 'respuesta': respuesta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncidenciasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? fecha,
    Value<String>? proveedor,
    Value<String>? productoId,
    Value<String>? producto,
    Value<FormaConteo>? forma,
    Value<String>? marca,
    Value<TipoIncidencia>? tipo,
    Value<int>? piezas,
    Value<int>? cantidad,
    Value<String>? nota,
    Value<bool>? sacada,
    Value<RespuestaProveedor?>? respuesta,
    Value<int>? rowid,
  }) {
    return IncidenciasCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      proveedor: proveedor ?? this.proveedor,
      productoId: productoId ?? this.productoId,
      producto: producto ?? this.producto,
      forma: forma ?? this.forma,
      marca: marca ?? this.marca,
      tipo: tipo ?? this.tipo,
      piezas: piezas ?? this.piezas,
      cantidad: cantidad ?? this.cantidad,
      nota: nota ?? this.nota,
      sacada: sacada ?? this.sacada,
      respuesta: respuesta ?? this.respuesta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (forma.present) {
      map['forma'] = Variable<String>(
        $IncidenciasTable.$converterforma.toSql(forma.value),
      );
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $IncidenciasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (piezas.present) {
      map['piezas'] = Variable<int>(piezas.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (sacada.present) {
      map['sacada'] = Variable<bool>(sacada.value);
    }
    if (respuesta.present) {
      map['respuesta'] = Variable<String>(
        $IncidenciasTable.$converterrespuestan.toSql(respuesta.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidenciasCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('proveedor: $proveedor, ')
          ..write('productoId: $productoId, ')
          ..write('producto: $producto, ')
          ..write('forma: $forma, ')
          ..write('marca: $marca, ')
          ..write('tipo: $tipo, ')
          ..write('piezas: $piezas, ')
          ..write('cantidad: $cantidad, ')
          ..write('nota: $nota, ')
          ..write('sacada: $sacada, ')
          ..write('respuesta: $respuesta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovimientosTable extends Movimientos
    with TableInfo<$MovimientosTable, FilaMovimiento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoMovimiento, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoMovimiento>($MovimientosTable.$convertertipo);
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FormaConteo, String> forma =
      GeneratedColumn<String>(
        'forma',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FormaConteo>($MovimientosTable.$converterforma);
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piezasMeta = const VerificationMeta('piezas');
  @override
  late final GeneratedColumn<int> piezas = GeneratedColumn<int>(
    'piezas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importeMeta = const VerificationMeta(
    'importe',
  );
  @override
  late final GeneratedColumn<int> importe = GeneratedColumn<int>(
    'importe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<int> costo = GeneratedColumn<int>(
    'costo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abrioPiezaMeta = const VerificationMeta(
    'abrioPieza',
  );
  @override
  late final GeneratedColumn<bool> abrioPieza = GeneratedColumn<bool>(
    'abrio_pieza',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("abrio_pieza" IN (0, 1))',
    ),
  );
  static const VerificationMeta _anuladaMeta = const VerificationMeta(
    'anulada',
  );
  @override
  late final GeneratedColumn<bool> anulada = GeneratedColumn<bool>(
    'anulada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("anulada" IN (0, 1))',
    ),
  );
  static const VerificationMeta _tasaMeta = const VerificationMeta('tasa');
  @override
  late final GeneratedColumn<int> tasa = GeneratedColumn<int>(
    'tasa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _origenIdMeta = const VerificationMeta(
    'origenId',
  );
  @override
  late final GeneratedColumn<String> origenId = GeneratedColumn<String>(
    'origen_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<String> ventaId = GeneratedColumn<String>(
    'venta_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    tipo,
    productoId,
    producto,
    forma,
    marca,
    proveedor,
    piezas,
    cantidad,
    importe,
    costo,
    abrioPieza,
    anulada,
    tasa,
    nota,
    origenId,
    ventaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaMovimiento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    } else if (isInserting) {
      context.missing(_productoMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    } else if (isInserting) {
      context.missing(_marcaMeta);
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    } else if (isInserting) {
      context.missing(_proveedorMeta);
    }
    if (data.containsKey('piezas')) {
      context.handle(
        _piezasMeta,
        piezas.isAcceptableOrUnknown(data['piezas']!, _piezasMeta),
      );
    } else if (isInserting) {
      context.missing(_piezasMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('importe')) {
      context.handle(
        _importeMeta,
        importe.isAcceptableOrUnknown(data['importe']!, _importeMeta),
      );
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    }
    if (data.containsKey('abrio_pieza')) {
      context.handle(
        _abrioPiezaMeta,
        abrioPieza.isAcceptableOrUnknown(data['abrio_pieza']!, _abrioPiezaMeta),
      );
    } else if (isInserting) {
      context.missing(_abrioPiezaMeta);
    }
    if (data.containsKey('anulada')) {
      context.handle(
        _anuladaMeta,
        anulada.isAcceptableOrUnknown(data['anulada']!, _anuladaMeta),
      );
    } else if (isInserting) {
      context.missing(_anuladaMeta);
    }
    if (data.containsKey('tasa')) {
      context.handle(
        _tasaMeta,
        tasa.isAcceptableOrUnknown(data['tasa']!, _tasaMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    } else if (isInserting) {
      context.missing(_notaMeta);
    }
    if (data.containsKey('origen_id')) {
      context.handle(
        _origenIdMeta,
        origenId.isAcceptableOrUnknown(data['origen_id']!, _origenIdMeta),
      );
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaMovimiento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaMovimiento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tipo: $MovimientosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      )!,
      forma: $MovimientosTable.$converterforma.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma'],
        )!,
      ),
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      )!,
      piezas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}piezas'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      importe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}importe'],
      ),
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo'],
      ),
      abrioPieza: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}abrio_pieza'],
      )!,
      anulada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}anulada'],
      )!,
      tasa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasa'],
      ),
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      )!,
      origenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen_id'],
      ),
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venta_id'],
      ),
    );
  }

  @override
  $MovimientosTable createAlias(String alias) {
    return $MovimientosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoMovimiento, String, String> $convertertipo =
      const EnumNameConverter<TipoMovimiento>(TipoMovimiento.values);
  static JsonTypeConverter2<FormaConteo, String, String> $converterforma =
      const EnumNameConverter<FormaConteo>(FormaConteo.values);
}

class FilaMovimiento extends DataClass implements Insertable<FilaMovimiento> {
  final String id;
  final DateTime fecha;
  final TipoMovimiento tipo;
  final String productoId;
  final String producto;
  final FormaConteo forma;
  final String marca;
  final String proveedor;
  final int piezas;
  final int cantidad;
  final int? importe;
  final int? costo;
  final bool abrioPieza;
  final bool anulada;
  final int? tasa;
  final String nota;
  final String? origenId;

  /// The paid ticket a sale line belongs to (schema 3).
  final String? ventaId;
  const FilaMovimiento({
    required this.id,
    required this.fecha,
    required this.tipo,
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    required this.proveedor,
    required this.piezas,
    required this.cantidad,
    this.importe,
    this.costo,
    required this.abrioPieza,
    required this.anulada,
    this.tasa,
    required this.nota,
    this.origenId,
    this.ventaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    {
      map['tipo'] = Variable<String>(
        $MovimientosTable.$convertertipo.toSql(tipo),
      );
    }
    map['producto_id'] = Variable<String>(productoId);
    map['producto'] = Variable<String>(producto);
    {
      map['forma'] = Variable<String>(
        $MovimientosTable.$converterforma.toSql(forma),
      );
    }
    map['marca'] = Variable<String>(marca);
    map['proveedor'] = Variable<String>(proveedor);
    map['piezas'] = Variable<int>(piezas);
    map['cantidad'] = Variable<int>(cantidad);
    if (!nullToAbsent || importe != null) {
      map['importe'] = Variable<int>(importe);
    }
    if (!nullToAbsent || costo != null) {
      map['costo'] = Variable<int>(costo);
    }
    map['abrio_pieza'] = Variable<bool>(abrioPieza);
    map['anulada'] = Variable<bool>(anulada);
    if (!nullToAbsent || tasa != null) {
      map['tasa'] = Variable<int>(tasa);
    }
    map['nota'] = Variable<String>(nota);
    if (!nullToAbsent || origenId != null) {
      map['origen_id'] = Variable<String>(origenId);
    }
    if (!nullToAbsent || ventaId != null) {
      map['venta_id'] = Variable<String>(ventaId);
    }
    return map;
  }

  MovimientosCompanion toCompanion(bool nullToAbsent) {
    return MovimientosCompanion(
      id: Value(id),
      fecha: Value(fecha),
      tipo: Value(tipo),
      productoId: Value(productoId),
      producto: Value(producto),
      forma: Value(forma),
      marca: Value(marca),
      proveedor: Value(proveedor),
      piezas: Value(piezas),
      cantidad: Value(cantidad),
      importe: importe == null && nullToAbsent
          ? const Value.absent()
          : Value(importe),
      costo: costo == null && nullToAbsent
          ? const Value.absent()
          : Value(costo),
      abrioPieza: Value(abrioPieza),
      anulada: Value(anulada),
      tasa: tasa == null && nullToAbsent ? const Value.absent() : Value(tasa),
      nota: Value(nota),
      origenId: origenId == null && nullToAbsent
          ? const Value.absent()
          : Value(origenId),
      ventaId: ventaId == null && nullToAbsent
          ? const Value.absent()
          : Value(ventaId),
    );
  }

  factory FilaMovimiento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaMovimiento(
      id: serializer.fromJson<String>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tipo: $MovimientosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      productoId: serializer.fromJson<String>(json['productoId']),
      producto: serializer.fromJson<String>(json['producto']),
      forma: $MovimientosTable.$converterforma.fromJson(
        serializer.fromJson<String>(json['forma']),
      ),
      marca: serializer.fromJson<String>(json['marca']),
      proveedor: serializer.fromJson<String>(json['proveedor']),
      piezas: serializer.fromJson<int>(json['piezas']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      importe: serializer.fromJson<int?>(json['importe']),
      costo: serializer.fromJson<int?>(json['costo']),
      abrioPieza: serializer.fromJson<bool>(json['abrioPieza']),
      anulada: serializer.fromJson<bool>(json['anulada']),
      tasa: serializer.fromJson<int?>(json['tasa']),
      nota: serializer.fromJson<String>(json['nota']),
      origenId: serializer.fromJson<String?>(json['origenId']),
      ventaId: serializer.fromJson<String?>(json['ventaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tipo': serializer.toJson<String>(
        $MovimientosTable.$convertertipo.toJson(tipo),
      ),
      'productoId': serializer.toJson<String>(productoId),
      'producto': serializer.toJson<String>(producto),
      'forma': serializer.toJson<String>(
        $MovimientosTable.$converterforma.toJson(forma),
      ),
      'marca': serializer.toJson<String>(marca),
      'proveedor': serializer.toJson<String>(proveedor),
      'piezas': serializer.toJson<int>(piezas),
      'cantidad': serializer.toJson<int>(cantidad),
      'importe': serializer.toJson<int?>(importe),
      'costo': serializer.toJson<int?>(costo),
      'abrioPieza': serializer.toJson<bool>(abrioPieza),
      'anulada': serializer.toJson<bool>(anulada),
      'tasa': serializer.toJson<int?>(tasa),
      'nota': serializer.toJson<String>(nota),
      'origenId': serializer.toJson<String?>(origenId),
      'ventaId': serializer.toJson<String?>(ventaId),
    };
  }

  FilaMovimiento copyWith({
    String? id,
    DateTime? fecha,
    TipoMovimiento? tipo,
    String? productoId,
    String? producto,
    FormaConteo? forma,
    String? marca,
    String? proveedor,
    int? piezas,
    int? cantidad,
    Value<int?> importe = const Value.absent(),
    Value<int?> costo = const Value.absent(),
    bool? abrioPieza,
    bool? anulada,
    Value<int?> tasa = const Value.absent(),
    String? nota,
    Value<String?> origenId = const Value.absent(),
    Value<String?> ventaId = const Value.absent(),
  }) => FilaMovimiento(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    tipo: tipo ?? this.tipo,
    productoId: productoId ?? this.productoId,
    producto: producto ?? this.producto,
    forma: forma ?? this.forma,
    marca: marca ?? this.marca,
    proveedor: proveedor ?? this.proveedor,
    piezas: piezas ?? this.piezas,
    cantidad: cantidad ?? this.cantidad,
    importe: importe.present ? importe.value : this.importe,
    costo: costo.present ? costo.value : this.costo,
    abrioPieza: abrioPieza ?? this.abrioPieza,
    anulada: anulada ?? this.anulada,
    tasa: tasa.present ? tasa.value : this.tasa,
    nota: nota ?? this.nota,
    origenId: origenId.present ? origenId.value : this.origenId,
    ventaId: ventaId.present ? ventaId.value : this.ventaId,
  );
  FilaMovimiento copyWithCompanion(MovimientosCompanion data) {
    return FilaMovimiento(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      producto: data.producto.present ? data.producto.value : this.producto,
      forma: data.forma.present ? data.forma.value : this.forma,
      marca: data.marca.present ? data.marca.value : this.marca,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      piezas: data.piezas.present ? data.piezas.value : this.piezas,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      importe: data.importe.present ? data.importe.value : this.importe,
      costo: data.costo.present ? data.costo.value : this.costo,
      abrioPieza: data.abrioPieza.present
          ? data.abrioPieza.value
          : this.abrioPieza,
      anulada: data.anulada.present ? data.anulada.value : this.anulada,
      tasa: data.tasa.present ? data.tasa.value : this.tasa,
      nota: data.nota.present ? data.nota.value : this.nota,
      origenId: data.origenId.present ? data.origenId.value : this.origenId,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaMovimiento(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('productoId: $productoId, ')
          ..write('producto: $producto, ')
          ..write('forma: $forma, ')
          ..write('marca: $marca, ')
          ..write('proveedor: $proveedor, ')
          ..write('piezas: $piezas, ')
          ..write('cantidad: $cantidad, ')
          ..write('importe: $importe, ')
          ..write('costo: $costo, ')
          ..write('abrioPieza: $abrioPieza, ')
          ..write('anulada: $anulada, ')
          ..write('tasa: $tasa, ')
          ..write('nota: $nota, ')
          ..write('origenId: $origenId, ')
          ..write('ventaId: $ventaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    tipo,
    productoId,
    producto,
    forma,
    marca,
    proveedor,
    piezas,
    cantidad,
    importe,
    costo,
    abrioPieza,
    anulada,
    tasa,
    nota,
    origenId,
    ventaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaMovimiento &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo &&
          other.productoId == this.productoId &&
          other.producto == this.producto &&
          other.forma == this.forma &&
          other.marca == this.marca &&
          other.proveedor == this.proveedor &&
          other.piezas == this.piezas &&
          other.cantidad == this.cantidad &&
          other.importe == this.importe &&
          other.costo == this.costo &&
          other.abrioPieza == this.abrioPieza &&
          other.anulada == this.anulada &&
          other.tasa == this.tasa &&
          other.nota == this.nota &&
          other.origenId == this.origenId &&
          other.ventaId == this.ventaId);
}

class MovimientosCompanion extends UpdateCompanion<FilaMovimiento> {
  final Value<String> id;
  final Value<DateTime> fecha;
  final Value<TipoMovimiento> tipo;
  final Value<String> productoId;
  final Value<String> producto;
  final Value<FormaConteo> forma;
  final Value<String> marca;
  final Value<String> proveedor;
  final Value<int> piezas;
  final Value<int> cantidad;
  final Value<int?> importe;
  final Value<int?> costo;
  final Value<bool> abrioPieza;
  final Value<bool> anulada;
  final Value<int?> tasa;
  final Value<String> nota;
  final Value<String?> origenId;
  final Value<String?> ventaId;
  final Value<int> rowid;
  const MovimientosCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.productoId = const Value.absent(),
    this.producto = const Value.absent(),
    this.forma = const Value.absent(),
    this.marca = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.piezas = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.importe = const Value.absent(),
    this.costo = const Value.absent(),
    this.abrioPieza = const Value.absent(),
    this.anulada = const Value.absent(),
    this.tasa = const Value.absent(),
    this.nota = const Value.absent(),
    this.origenId = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovimientosCompanion.insert({
    required String id,
    required DateTime fecha,
    required TipoMovimiento tipo,
    required String productoId,
    required String producto,
    required FormaConteo forma,
    required String marca,
    required String proveedor,
    required int piezas,
    required int cantidad,
    this.importe = const Value.absent(),
    this.costo = const Value.absent(),
    required bool abrioPieza,
    required bool anulada,
    this.tasa = const Value.absent(),
    required String nota,
    this.origenId = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       tipo = Value(tipo),
       productoId = Value(productoId),
       producto = Value(producto),
       forma = Value(forma),
       marca = Value(marca),
       proveedor = Value(proveedor),
       piezas = Value(piezas),
       cantidad = Value(cantidad),
       abrioPieza = Value(abrioPieza),
       anulada = Value(anulada),
       nota = Value(nota);
  static Insertable<FilaMovimiento> custom({
    Expression<String>? id,
    Expression<DateTime>? fecha,
    Expression<String>? tipo,
    Expression<String>? productoId,
    Expression<String>? producto,
    Expression<String>? forma,
    Expression<String>? marca,
    Expression<String>? proveedor,
    Expression<int>? piezas,
    Expression<int>? cantidad,
    Expression<int>? importe,
    Expression<int>? costo,
    Expression<bool>? abrioPieza,
    Expression<bool>? anulada,
    Expression<int>? tasa,
    Expression<String>? nota,
    Expression<String>? origenId,
    Expression<String>? ventaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
      if (productoId != null) 'producto_id': productoId,
      if (producto != null) 'producto': producto,
      if (forma != null) 'forma': forma,
      if (marca != null) 'marca': marca,
      if (proveedor != null) 'proveedor': proveedor,
      if (piezas != null) 'piezas': piezas,
      if (cantidad != null) 'cantidad': cantidad,
      if (importe != null) 'importe': importe,
      if (costo != null) 'costo': costo,
      if (abrioPieza != null) 'abrio_pieza': abrioPieza,
      if (anulada != null) 'anulada': anulada,
      if (tasa != null) 'tasa': tasa,
      if (nota != null) 'nota': nota,
      if (origenId != null) 'origen_id': origenId,
      if (ventaId != null) 'venta_id': ventaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovimientosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? fecha,
    Value<TipoMovimiento>? tipo,
    Value<String>? productoId,
    Value<String>? producto,
    Value<FormaConteo>? forma,
    Value<String>? marca,
    Value<String>? proveedor,
    Value<int>? piezas,
    Value<int>? cantidad,
    Value<int?>? importe,
    Value<int?>? costo,
    Value<bool>? abrioPieza,
    Value<bool>? anulada,
    Value<int?>? tasa,
    Value<String>? nota,
    Value<String?>? origenId,
    Value<String?>? ventaId,
    Value<int>? rowid,
  }) {
    return MovimientosCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      productoId: productoId ?? this.productoId,
      producto: producto ?? this.producto,
      forma: forma ?? this.forma,
      marca: marca ?? this.marca,
      proveedor: proveedor ?? this.proveedor,
      piezas: piezas ?? this.piezas,
      cantidad: cantidad ?? this.cantidad,
      importe: importe ?? this.importe,
      costo: costo ?? this.costo,
      abrioPieza: abrioPieza ?? this.abrioPieza,
      anulada: anulada ?? this.anulada,
      tasa: tasa ?? this.tasa,
      nota: nota ?? this.nota,
      origenId: origenId ?? this.origenId,
      ventaId: ventaId ?? this.ventaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $MovimientosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (forma.present) {
      map['forma'] = Variable<String>(
        $MovimientosTable.$converterforma.toSql(forma.value),
      );
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (piezas.present) {
      map['piezas'] = Variable<int>(piezas.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (importe.present) {
      map['importe'] = Variable<int>(importe.value);
    }
    if (costo.present) {
      map['costo'] = Variable<int>(costo.value);
    }
    if (abrioPieza.present) {
      map['abrio_pieza'] = Variable<bool>(abrioPieza.value);
    }
    if (anulada.present) {
      map['anulada'] = Variable<bool>(anulada.value);
    }
    if (tasa.present) {
      map['tasa'] = Variable<int>(tasa.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (origenId.present) {
      map['origen_id'] = Variable<String>(origenId.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<String>(ventaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('productoId: $productoId, ')
          ..write('producto: $producto, ')
          ..write('forma: $forma, ')
          ..write('marca: $marca, ')
          ..write('proveedor: $proveedor, ')
          ..write('piezas: $piezas, ')
          ..write('cantidad: $cantidad, ')
          ..write('importe: $importe, ')
          ..write('costo: $costo, ')
          ..write('abrioPieza: $abrioPieza, ')
          ..write('anulada: $anulada, ')
          ..write('tasa: $tasa, ')
          ..write('nota: $nota, ')
          ..write('origenId: $origenId, ')
          ..write('ventaId: $ventaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComprasTable extends Compras with TableInfo<$ComprasTable, FilaCompra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facturaMeta = const VerificationMeta(
    'factura',
  );
  @override
  late final GeneratedColumn<String> factura = GeneratedColumn<String>(
    'factura',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _venceMeta = const VerificationMeta('vence');
  @override
  late final GeneratedColumn<DateTime> vence = GeneratedColumn<DateTime>(
    'vence',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedioPago?, String> medio =
      GeneratedColumn<String>(
        'medio',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MedioPago?>($ComprasTable.$convertermedion);
  static const VerificationMeta _tasaMeta = const VerificationMeta('tasa');
  @override
  late final GeneratedColumn<int> tasa = GeneratedColumn<int>(
    'tasa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    proveedor,
    factura,
    vence,
    medio,
    tasa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaCompra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    } else if (isInserting) {
      context.missing(_proveedorMeta);
    }
    if (data.containsKey('factura')) {
      context.handle(
        _facturaMeta,
        factura.isAcceptableOrUnknown(data['factura']!, _facturaMeta),
      );
    } else if (isInserting) {
      context.missing(_facturaMeta);
    }
    if (data.containsKey('vence')) {
      context.handle(
        _venceMeta,
        vence.isAcceptableOrUnknown(data['vence']!, _venceMeta),
      );
    }
    if (data.containsKey('tasa')) {
      context.handle(
        _tasaMeta,
        tasa.isAcceptableOrUnknown(data['tasa']!, _tasaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaCompra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaCompra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      )!,
      factura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}factura'],
      )!,
      vence: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}vence'],
      ),
      medio: $ComprasTable.$convertermedion.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}medio'],
        ),
      ),
      tasa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasa'],
      ),
    );
  }

  @override
  $ComprasTable createAlias(String alias) {
    return $ComprasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MedioPago, String, String> $convertermedio =
      const EnumNameConverter<MedioPago>(MedioPago.values);
  static JsonTypeConverter2<MedioPago?, String?, String?> $convertermedion =
      JsonTypeConverter2.asNullable($convertermedio);
}

class FilaCompra extends DataClass implements Insertable<FilaCompra> {
  final String id;
  final DateTime fecha;
  final String proveedor;
  final String factura;
  final DateTime? vence;
  final MedioPago? medio;
  final int? tasa;
  const FilaCompra({
    required this.id,
    required this.fecha,
    required this.proveedor,
    required this.factura,
    this.vence,
    this.medio,
    this.tasa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['proveedor'] = Variable<String>(proveedor);
    map['factura'] = Variable<String>(factura);
    if (!nullToAbsent || vence != null) {
      map['vence'] = Variable<DateTime>(vence);
    }
    if (!nullToAbsent || medio != null) {
      map['medio'] = Variable<String>(
        $ComprasTable.$convertermedion.toSql(medio),
      );
    }
    if (!nullToAbsent || tasa != null) {
      map['tasa'] = Variable<int>(tasa);
    }
    return map;
  }

  ComprasCompanion toCompanion(bool nullToAbsent) {
    return ComprasCompanion(
      id: Value(id),
      fecha: Value(fecha),
      proveedor: Value(proveedor),
      factura: Value(factura),
      vence: vence == null && nullToAbsent
          ? const Value.absent()
          : Value(vence),
      medio: medio == null && nullToAbsent
          ? const Value.absent()
          : Value(medio),
      tasa: tasa == null && nullToAbsent ? const Value.absent() : Value(tasa),
    );
  }

  factory FilaCompra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaCompra(
      id: serializer.fromJson<String>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      proveedor: serializer.fromJson<String>(json['proveedor']),
      factura: serializer.fromJson<String>(json['factura']),
      vence: serializer.fromJson<DateTime?>(json['vence']),
      medio: $ComprasTable.$convertermedion.fromJson(
        serializer.fromJson<String?>(json['medio']),
      ),
      tasa: serializer.fromJson<int?>(json['tasa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'proveedor': serializer.toJson<String>(proveedor),
      'factura': serializer.toJson<String>(factura),
      'vence': serializer.toJson<DateTime?>(vence),
      'medio': serializer.toJson<String?>(
        $ComprasTable.$convertermedion.toJson(medio),
      ),
      'tasa': serializer.toJson<int?>(tasa),
    };
  }

  FilaCompra copyWith({
    String? id,
    DateTime? fecha,
    String? proveedor,
    String? factura,
    Value<DateTime?> vence = const Value.absent(),
    Value<MedioPago?> medio = const Value.absent(),
    Value<int?> tasa = const Value.absent(),
  }) => FilaCompra(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    proveedor: proveedor ?? this.proveedor,
    factura: factura ?? this.factura,
    vence: vence.present ? vence.value : this.vence,
    medio: medio.present ? medio.value : this.medio,
    tasa: tasa.present ? tasa.value : this.tasa,
  );
  FilaCompra copyWithCompanion(ComprasCompanion data) {
    return FilaCompra(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      factura: data.factura.present ? data.factura.value : this.factura,
      vence: data.vence.present ? data.vence.value : this.vence,
      medio: data.medio.present ? data.medio.value : this.medio,
      tasa: data.tasa.present ? data.tasa.value : this.tasa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaCompra(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('proveedor: $proveedor, ')
          ..write('factura: $factura, ')
          ..write('vence: $vence, ')
          ..write('medio: $medio, ')
          ..write('tasa: $tasa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fecha, proveedor, factura, vence, medio, tasa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaCompra &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.proveedor == this.proveedor &&
          other.factura == this.factura &&
          other.vence == this.vence &&
          other.medio == this.medio &&
          other.tasa == this.tasa);
}

class ComprasCompanion extends UpdateCompanion<FilaCompra> {
  final Value<String> id;
  final Value<DateTime> fecha;
  final Value<String> proveedor;
  final Value<String> factura;
  final Value<DateTime?> vence;
  final Value<MedioPago?> medio;
  final Value<int?> tasa;
  final Value<int> rowid;
  const ComprasCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.factura = const Value.absent(),
    this.vence = const Value.absent(),
    this.medio = const Value.absent(),
    this.tasa = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComprasCompanion.insert({
    required String id,
    required DateTime fecha,
    required String proveedor,
    required String factura,
    this.vence = const Value.absent(),
    this.medio = const Value.absent(),
    this.tasa = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       proveedor = Value(proveedor),
       factura = Value(factura);
  static Insertable<FilaCompra> custom({
    Expression<String>? id,
    Expression<DateTime>? fecha,
    Expression<String>? proveedor,
    Expression<String>? factura,
    Expression<DateTime>? vence,
    Expression<String>? medio,
    Expression<int>? tasa,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (proveedor != null) 'proveedor': proveedor,
      if (factura != null) 'factura': factura,
      if (vence != null) 'vence': vence,
      if (medio != null) 'medio': medio,
      if (tasa != null) 'tasa': tasa,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComprasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? fecha,
    Value<String>? proveedor,
    Value<String>? factura,
    Value<DateTime?>? vence,
    Value<MedioPago?>? medio,
    Value<int?>? tasa,
    Value<int>? rowid,
  }) {
    return ComprasCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      proveedor: proveedor ?? this.proveedor,
      factura: factura ?? this.factura,
      vence: vence ?? this.vence,
      medio: medio ?? this.medio,
      tasa: tasa ?? this.tasa,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (factura.present) {
      map['factura'] = Variable<String>(factura.value);
    }
    if (vence.present) {
      map['vence'] = Variable<DateTime>(vence.value);
    }
    if (medio.present) {
      map['medio'] = Variable<String>(
        $ComprasTable.$convertermedion.toSql(medio.value),
      );
    }
    if (tasa.present) {
      map['tasa'] = Variable<int>(tasa.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('proveedor: $proveedor, ')
          ..write('factura: $factura, ')
          ..write('vence: $vence, ')
          ..write('medio: $medio, ')
          ..write('tasa: $tasa, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineasCompraTable extends LineasCompra
    with TableInfo<$LineasCompraTable, FilaLineaCompra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineasCompraTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _compraIdMeta = const VerificationMeta(
    'compraId',
  );
  @override
  late final GeneratedColumn<String> compraId = GeneratedColumn<String>(
    'compra_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compras (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FormaConteo, String> forma =
      GeneratedColumn<String>(
        'forma',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FormaConteo>($LineasCompraTable.$converterforma);
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _piezasMeta = const VerificationMeta('piezas');
  @override
  late final GeneratedColumn<int> piezas = GeneratedColumn<int>(
    'piezas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<int> costo = GeneratedColumn<int>(
    'costo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    compraId,
    orden,
    productoId,
    producto,
    forma,
    marca,
    piezas,
    cantidad,
    costo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lineas_compra';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaLineaCompra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('compra_id')) {
      context.handle(
        _compraIdMeta,
        compraId.isAcceptableOrUnknown(data['compra_id']!, _compraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_compraIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    } else if (isInserting) {
      context.missing(_productoMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    } else if (isInserting) {
      context.missing(_marcaMeta);
    }
    if (data.containsKey('piezas')) {
      context.handle(
        _piezasMeta,
        piezas.isAcceptableOrUnknown(data['piezas']!, _piezasMeta),
      );
    } else if (isInserting) {
      context.missing(_piezasMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    } else if (isInserting) {
      context.missing(_costoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaLineaCompra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaLineaCompra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      compraId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compra_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      )!,
      forma: $LineasCompraTable.$converterforma.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma'],
        )!,
      ),
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      piezas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}piezas'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo'],
      )!,
    );
  }

  @override
  $LineasCompraTable createAlias(String alias) {
    return $LineasCompraTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FormaConteo, String, String> $converterforma =
      const EnumNameConverter<FormaConteo>(FormaConteo.values);
}

class FilaLineaCompra extends DataClass implements Insertable<FilaLineaCompra> {
  final int id;
  final String compraId;
  final int orden;
  final String productoId;
  final String producto;
  final FormaConteo forma;
  final String marca;
  final int piezas;
  final int cantidad;
  final int costo;
  const FilaLineaCompra({
    required this.id,
    required this.compraId,
    required this.orden,
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    required this.piezas,
    required this.cantidad,
    required this.costo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['compra_id'] = Variable<String>(compraId);
    map['orden'] = Variable<int>(orden);
    map['producto_id'] = Variable<String>(productoId);
    map['producto'] = Variable<String>(producto);
    {
      map['forma'] = Variable<String>(
        $LineasCompraTable.$converterforma.toSql(forma),
      );
    }
    map['marca'] = Variable<String>(marca);
    map['piezas'] = Variable<int>(piezas);
    map['cantidad'] = Variable<int>(cantidad);
    map['costo'] = Variable<int>(costo);
    return map;
  }

  LineasCompraCompanion toCompanion(bool nullToAbsent) {
    return LineasCompraCompanion(
      id: Value(id),
      compraId: Value(compraId),
      orden: Value(orden),
      productoId: Value(productoId),
      producto: Value(producto),
      forma: Value(forma),
      marca: Value(marca),
      piezas: Value(piezas),
      cantidad: Value(cantidad),
      costo: Value(costo),
    );
  }

  factory FilaLineaCompra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaLineaCompra(
      id: serializer.fromJson<int>(json['id']),
      compraId: serializer.fromJson<String>(json['compraId']),
      orden: serializer.fromJson<int>(json['orden']),
      productoId: serializer.fromJson<String>(json['productoId']),
      producto: serializer.fromJson<String>(json['producto']),
      forma: $LineasCompraTable.$converterforma.fromJson(
        serializer.fromJson<String>(json['forma']),
      ),
      marca: serializer.fromJson<String>(json['marca']),
      piezas: serializer.fromJson<int>(json['piezas']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      costo: serializer.fromJson<int>(json['costo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'compraId': serializer.toJson<String>(compraId),
      'orden': serializer.toJson<int>(orden),
      'productoId': serializer.toJson<String>(productoId),
      'producto': serializer.toJson<String>(producto),
      'forma': serializer.toJson<String>(
        $LineasCompraTable.$converterforma.toJson(forma),
      ),
      'marca': serializer.toJson<String>(marca),
      'piezas': serializer.toJson<int>(piezas),
      'cantidad': serializer.toJson<int>(cantidad),
      'costo': serializer.toJson<int>(costo),
    };
  }

  FilaLineaCompra copyWith({
    int? id,
    String? compraId,
    int? orden,
    String? productoId,
    String? producto,
    FormaConteo? forma,
    String? marca,
    int? piezas,
    int? cantidad,
    int? costo,
  }) => FilaLineaCompra(
    id: id ?? this.id,
    compraId: compraId ?? this.compraId,
    orden: orden ?? this.orden,
    productoId: productoId ?? this.productoId,
    producto: producto ?? this.producto,
    forma: forma ?? this.forma,
    marca: marca ?? this.marca,
    piezas: piezas ?? this.piezas,
    cantidad: cantidad ?? this.cantidad,
    costo: costo ?? this.costo,
  );
  FilaLineaCompra copyWithCompanion(LineasCompraCompanion data) {
    return FilaLineaCompra(
      id: data.id.present ? data.id.value : this.id,
      compraId: data.compraId.present ? data.compraId.value : this.compraId,
      orden: data.orden.present ? data.orden.value : this.orden,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      producto: data.producto.present ? data.producto.value : this.producto,
      forma: data.forma.present ? data.forma.value : this.forma,
      marca: data.marca.present ? data.marca.value : this.marca,
      piezas: data.piezas.present ? data.piezas.value : this.piezas,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      costo: data.costo.present ? data.costo.value : this.costo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaLineaCompra(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('orden: $orden, ')
          ..write('productoId: $productoId, ')
          ..write('producto: $producto, ')
          ..write('forma: $forma, ')
          ..write('marca: $marca, ')
          ..write('piezas: $piezas, ')
          ..write('cantidad: $cantidad, ')
          ..write('costo: $costo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    compraId,
    orden,
    productoId,
    producto,
    forma,
    marca,
    piezas,
    cantidad,
    costo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaLineaCompra &&
          other.id == this.id &&
          other.compraId == this.compraId &&
          other.orden == this.orden &&
          other.productoId == this.productoId &&
          other.producto == this.producto &&
          other.forma == this.forma &&
          other.marca == this.marca &&
          other.piezas == this.piezas &&
          other.cantidad == this.cantidad &&
          other.costo == this.costo);
}

class LineasCompraCompanion extends UpdateCompanion<FilaLineaCompra> {
  final Value<int> id;
  final Value<String> compraId;
  final Value<int> orden;
  final Value<String> productoId;
  final Value<String> producto;
  final Value<FormaConteo> forma;
  final Value<String> marca;
  final Value<int> piezas;
  final Value<int> cantidad;
  final Value<int> costo;
  const LineasCompraCompanion({
    this.id = const Value.absent(),
    this.compraId = const Value.absent(),
    this.orden = const Value.absent(),
    this.productoId = const Value.absent(),
    this.producto = const Value.absent(),
    this.forma = const Value.absent(),
    this.marca = const Value.absent(),
    this.piezas = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.costo = const Value.absent(),
  });
  LineasCompraCompanion.insert({
    this.id = const Value.absent(),
    required String compraId,
    required int orden,
    required String productoId,
    required String producto,
    required FormaConteo forma,
    required String marca,
    required int piezas,
    required int cantidad,
    required int costo,
  }) : compraId = Value(compraId),
       orden = Value(orden),
       productoId = Value(productoId),
       producto = Value(producto),
       forma = Value(forma),
       marca = Value(marca),
       piezas = Value(piezas),
       cantidad = Value(cantidad),
       costo = Value(costo);
  static Insertable<FilaLineaCompra> custom({
    Expression<int>? id,
    Expression<String>? compraId,
    Expression<int>? orden,
    Expression<String>? productoId,
    Expression<String>? producto,
    Expression<String>? forma,
    Expression<String>? marca,
    Expression<int>? piezas,
    Expression<int>? cantidad,
    Expression<int>? costo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (compraId != null) 'compra_id': compraId,
      if (orden != null) 'orden': orden,
      if (productoId != null) 'producto_id': productoId,
      if (producto != null) 'producto': producto,
      if (forma != null) 'forma': forma,
      if (marca != null) 'marca': marca,
      if (piezas != null) 'piezas': piezas,
      if (cantidad != null) 'cantidad': cantidad,
      if (costo != null) 'costo': costo,
    });
  }

  LineasCompraCompanion copyWith({
    Value<int>? id,
    Value<String>? compraId,
    Value<int>? orden,
    Value<String>? productoId,
    Value<String>? producto,
    Value<FormaConteo>? forma,
    Value<String>? marca,
    Value<int>? piezas,
    Value<int>? cantidad,
    Value<int>? costo,
  }) {
    return LineasCompraCompanion(
      id: id ?? this.id,
      compraId: compraId ?? this.compraId,
      orden: orden ?? this.orden,
      productoId: productoId ?? this.productoId,
      producto: producto ?? this.producto,
      forma: forma ?? this.forma,
      marca: marca ?? this.marca,
      piezas: piezas ?? this.piezas,
      cantidad: cantidad ?? this.cantidad,
      costo: costo ?? this.costo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (compraId.present) {
      map['compra_id'] = Variable<String>(compraId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (forma.present) {
      map['forma'] = Variable<String>(
        $LineasCompraTable.$converterforma.toSql(forma.value),
      );
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (piezas.present) {
      map['piezas'] = Variable<int>(piezas.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (costo.present) {
      map['costo'] = Variable<int>(costo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineasCompraCompanion(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('orden: $orden, ')
          ..write('productoId: $productoId, ')
          ..write('producto: $producto, ')
          ..write('forma: $forma, ')
          ..write('marca: $marca, ')
          ..write('piezas: $piezas, ')
          ..write('cantidad: $cantidad, ')
          ..write('costo: $costo')
          ..write(')'))
        .toString();
  }
}

class $PagosTable extends Pagos with TableInfo<$PagosTable, FilaPago> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _compraIdMeta = const VerificationMeta(
    'compraId',
  );
  @override
  late final GeneratedColumn<String> compraId = GeneratedColumn<String>(
    'compra_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compras (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedioPago, String> medio =
      GeneratedColumn<String>(
        'medio',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MedioPago>($PagosTable.$convertermedio);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entregadoMeta = const VerificationMeta(
    'entregado',
  );
  @override
  late final GeneratedColumn<int> entregado = GeneratedColumn<int>(
    'entregado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tasaMeta = const VerificationMeta('tasa');
  @override
  late final GeneratedColumn<int> tasa = GeneratedColumn<int>(
    'tasa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenciaMeta = const VerificationMeta(
    'referencia',
  );
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
    'referencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    compraId,
    fecha,
    medio,
    monto,
    entregado,
    tasa,
    referencia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaPago> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('compra_id')) {
      context.handle(
        _compraIdMeta,
        compraId.isAcceptableOrUnknown(data['compra_id']!, _compraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_compraIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('entregado')) {
      context.handle(
        _entregadoMeta,
        entregado.isAcceptableOrUnknown(data['entregado']!, _entregadoMeta),
      );
    } else if (isInserting) {
      context.missing(_entregadoMeta);
    }
    if (data.containsKey('tasa')) {
      context.handle(
        _tasaMeta,
        tasa.isAcceptableOrUnknown(data['tasa']!, _tasaMeta),
      );
    }
    if (data.containsKey('referencia')) {
      context.handle(
        _referenciaMeta,
        referencia.isAcceptableOrUnknown(data['referencia']!, _referenciaMeta),
      );
    } else if (isInserting) {
      context.missing(_referenciaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaPago map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaPago(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      compraId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compra_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      medio: $PagosTable.$convertermedio.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}medio'],
        )!,
      ),
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      entregado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entregado'],
      )!,
      tasa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasa'],
      ),
      referencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia'],
      )!,
    );
  }

  @override
  $PagosTable createAlias(String alias) {
    return $PagosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MedioPago, String, String> $convertermedio =
      const EnumNameConverter<MedioPago>(MedioPago.values);
}

class FilaPago extends DataClass implements Insertable<FilaPago> {
  final String id;
  final String compraId;
  final DateTime fecha;
  final MedioPago medio;
  final int monto;
  final int entregado;
  final int? tasa;
  final String referencia;
  const FilaPago({
    required this.id,
    required this.compraId,
    required this.fecha,
    required this.medio,
    required this.monto,
    required this.entregado,
    this.tasa,
    required this.referencia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['compra_id'] = Variable<String>(compraId);
    map['fecha'] = Variable<DateTime>(fecha);
    {
      map['medio'] = Variable<String>($PagosTable.$convertermedio.toSql(medio));
    }
    map['monto'] = Variable<int>(monto);
    map['entregado'] = Variable<int>(entregado);
    if (!nullToAbsent || tasa != null) {
      map['tasa'] = Variable<int>(tasa);
    }
    map['referencia'] = Variable<String>(referencia);
    return map;
  }

  PagosCompanion toCompanion(bool nullToAbsent) {
    return PagosCompanion(
      id: Value(id),
      compraId: Value(compraId),
      fecha: Value(fecha),
      medio: Value(medio),
      monto: Value(monto),
      entregado: Value(entregado),
      tasa: tasa == null && nullToAbsent ? const Value.absent() : Value(tasa),
      referencia: Value(referencia),
    );
  }

  factory FilaPago.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaPago(
      id: serializer.fromJson<String>(json['id']),
      compraId: serializer.fromJson<String>(json['compraId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      medio: $PagosTable.$convertermedio.fromJson(
        serializer.fromJson<String>(json['medio']),
      ),
      monto: serializer.fromJson<int>(json['monto']),
      entregado: serializer.fromJson<int>(json['entregado']),
      tasa: serializer.fromJson<int?>(json['tasa']),
      referencia: serializer.fromJson<String>(json['referencia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'compraId': serializer.toJson<String>(compraId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'medio': serializer.toJson<String>(
        $PagosTable.$convertermedio.toJson(medio),
      ),
      'monto': serializer.toJson<int>(monto),
      'entregado': serializer.toJson<int>(entregado),
      'tasa': serializer.toJson<int?>(tasa),
      'referencia': serializer.toJson<String>(referencia),
    };
  }

  FilaPago copyWith({
    String? id,
    String? compraId,
    DateTime? fecha,
    MedioPago? medio,
    int? monto,
    int? entregado,
    Value<int?> tasa = const Value.absent(),
    String? referencia,
  }) => FilaPago(
    id: id ?? this.id,
    compraId: compraId ?? this.compraId,
    fecha: fecha ?? this.fecha,
    medio: medio ?? this.medio,
    monto: monto ?? this.monto,
    entregado: entregado ?? this.entregado,
    tasa: tasa.present ? tasa.value : this.tasa,
    referencia: referencia ?? this.referencia,
  );
  FilaPago copyWithCompanion(PagosCompanion data) {
    return FilaPago(
      id: data.id.present ? data.id.value : this.id,
      compraId: data.compraId.present ? data.compraId.value : this.compraId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      medio: data.medio.present ? data.medio.value : this.medio,
      monto: data.monto.present ? data.monto.value : this.monto,
      entregado: data.entregado.present ? data.entregado.value : this.entregado,
      tasa: data.tasa.present ? data.tasa.value : this.tasa,
      referencia: data.referencia.present
          ? data.referencia.value
          : this.referencia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaPago(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('fecha: $fecha, ')
          ..write('medio: $medio, ')
          ..write('monto: $monto, ')
          ..write('entregado: $entregado, ')
          ..write('tasa: $tasa, ')
          ..write('referencia: $referencia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    compraId,
    fecha,
    medio,
    monto,
    entregado,
    tasa,
    referencia,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaPago &&
          other.id == this.id &&
          other.compraId == this.compraId &&
          other.fecha == this.fecha &&
          other.medio == this.medio &&
          other.monto == this.monto &&
          other.entregado == this.entregado &&
          other.tasa == this.tasa &&
          other.referencia == this.referencia);
}

class PagosCompanion extends UpdateCompanion<FilaPago> {
  final Value<String> id;
  final Value<String> compraId;
  final Value<DateTime> fecha;
  final Value<MedioPago> medio;
  final Value<int> monto;
  final Value<int> entregado;
  final Value<int?> tasa;
  final Value<String> referencia;
  final Value<int> rowid;
  const PagosCompanion({
    this.id = const Value.absent(),
    this.compraId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.medio = const Value.absent(),
    this.monto = const Value.absent(),
    this.entregado = const Value.absent(),
    this.tasa = const Value.absent(),
    this.referencia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagosCompanion.insert({
    required String id,
    required String compraId,
    required DateTime fecha,
    required MedioPago medio,
    required int monto,
    required int entregado,
    this.tasa = const Value.absent(),
    required String referencia,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       compraId = Value(compraId),
       fecha = Value(fecha),
       medio = Value(medio),
       monto = Value(monto),
       entregado = Value(entregado),
       referencia = Value(referencia);
  static Insertable<FilaPago> custom({
    Expression<String>? id,
    Expression<String>? compraId,
    Expression<DateTime>? fecha,
    Expression<String>? medio,
    Expression<int>? monto,
    Expression<int>? entregado,
    Expression<int>? tasa,
    Expression<String>? referencia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (compraId != null) 'compra_id': compraId,
      if (fecha != null) 'fecha': fecha,
      if (medio != null) 'medio': medio,
      if (monto != null) 'monto': monto,
      if (entregado != null) 'entregado': entregado,
      if (tasa != null) 'tasa': tasa,
      if (referencia != null) 'referencia': referencia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagosCompanion copyWith({
    Value<String>? id,
    Value<String>? compraId,
    Value<DateTime>? fecha,
    Value<MedioPago>? medio,
    Value<int>? monto,
    Value<int>? entregado,
    Value<int?>? tasa,
    Value<String>? referencia,
    Value<int>? rowid,
  }) {
    return PagosCompanion(
      id: id ?? this.id,
      compraId: compraId ?? this.compraId,
      fecha: fecha ?? this.fecha,
      medio: medio ?? this.medio,
      monto: monto ?? this.monto,
      entregado: entregado ?? this.entregado,
      tasa: tasa ?? this.tasa,
      referencia: referencia ?? this.referencia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (compraId.present) {
      map['compra_id'] = Variable<String>(compraId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (medio.present) {
      map['medio'] = Variable<String>(
        $PagosTable.$convertermedio.toSql(medio.value),
      );
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (entregado.present) {
      map['entregado'] = Variable<int>(entregado.value);
    }
    if (tasa.present) {
      map['tasa'] = Variable<int>(tasa.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosCompanion(')
          ..write('id: $id, ')
          ..write('compraId: $compraId, ')
          ..write('fecha: $fecha, ')
          ..write('medio: $medio, ')
          ..write('monto: $monto, ')
          ..write('entregado: $entregado, ')
          ..write('tasa: $tasa, ')
          ..write('referencia: $referencia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, FilaVenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tasaMeta = const VerificationMeta('tasa');
  @override
  late final GeneratedColumn<int> tasa = GeneratedColumn<int>(
    'tasa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fecha, total, tasa];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaVenta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('tasa')) {
      context.handle(
        _tasaMeta,
        tasa.isAcceptableOrUnknown(data['tasa']!, _tasaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaVenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaVenta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      tasa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasa'],
      ),
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class FilaVenta extends DataClass implements Insertable<FilaVenta> {
  final String id;
  final DateTime fecha;
  final int total;
  final int? tasa;
  const FilaVenta({
    required this.id,
    required this.fecha,
    required this.total,
    this.tasa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['total'] = Variable<int>(total);
    if (!nullToAbsent || tasa != null) {
      map['tasa'] = Variable<int>(tasa);
    }
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      fecha: Value(fecha),
      total: Value(total),
      tasa: tasa == null && nullToAbsent ? const Value.absent() : Value(tasa),
    );
  }

  factory FilaVenta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaVenta(
      id: serializer.fromJson<String>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      total: serializer.fromJson<int>(json['total']),
      tasa: serializer.fromJson<int?>(json['tasa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'total': serializer.toJson<int>(total),
      'tasa': serializer.toJson<int?>(tasa),
    };
  }

  FilaVenta copyWith({
    String? id,
    DateTime? fecha,
    int? total,
    Value<int?> tasa = const Value.absent(),
  }) => FilaVenta(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    total: total ?? this.total,
    tasa: tasa.present ? tasa.value : this.tasa,
  );
  FilaVenta copyWithCompanion(VentasCompanion data) {
    return FilaVenta(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      total: data.total.present ? data.total.value : this.total,
      tasa: data.tasa.present ? data.tasa.value : this.tasa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaVenta(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total, ')
          ..write('tasa: $tasa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fecha, total, tasa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaVenta &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.total == this.total &&
          other.tasa == this.tasa);
}

class VentasCompanion extends UpdateCompanion<FilaVenta> {
  final Value<String> id;
  final Value<DateTime> fecha;
  final Value<int> total;
  final Value<int?> tasa;
  final Value<int> rowid;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.total = const Value.absent(),
    this.tasa = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentasCompanion.insert({
    required String id,
    required DateTime fecha,
    required int total,
    this.tasa = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       total = Value(total);
  static Insertable<FilaVenta> custom({
    Expression<String>? id,
    Expression<DateTime>? fecha,
    Expression<int>? total,
    Expression<int>? tasa,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (total != null) 'total': total,
      if (tasa != null) 'tasa': tasa,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? fecha,
    Value<int>? total,
    Value<int?>? tasa,
    Value<int>? rowid,
  }) {
    return VentasCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      tasa: tasa ?? this.tasa,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (tasa.present) {
      map['tasa'] = Variable<int>(tasa.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('total: $total, ')
          ..write('tasa: $tasa, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PagosVentaTable extends PagosVenta
    with TableInfo<$PagosVentaTable, FilaPagoVenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosVentaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<String> ventaId = GeneratedColumn<String>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ventas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedioPago, String> medio =
      GeneratedColumn<String>(
        'medio',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MedioPago>($PagosVentaTable.$convertermedio);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenciaMeta = const VerificationMeta(
    'referencia',
  );
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
    'referencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ventaId,
    orden,
    medio,
    monto,
    referencia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos_venta';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaPagoVenta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('referencia')) {
      context.handle(
        _referenciaMeta,
        referencia.isAcceptableOrUnknown(data['referencia']!, _referenciaMeta),
      );
    } else if (isInserting) {
      context.missing(_referenciaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ventaId, orden};
  @override
  FilaPagoVenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaPagoVenta(
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venta_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      medio: $PagosVentaTable.$convertermedio.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}medio'],
        )!,
      ),
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      referencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia'],
      )!,
    );
  }

  @override
  $PagosVentaTable createAlias(String alias) {
    return $PagosVentaTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MedioPago, String, String> $convertermedio =
      const EnumNameConverter<MedioPago>(MedioPago.values);
}

class FilaPagoVenta extends DataClass implements Insertable<FilaPagoVenta> {
  final String ventaId;

  /// Keeps the payments of a mixed sale in the order they were added.
  final int orden;
  final MedioPago medio;

  /// Hundredths of the payment's own currency.
  final int monto;
  final String referencia;
  const FilaPagoVenta({
    required this.ventaId,
    required this.orden,
    required this.medio,
    required this.monto,
    required this.referencia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['venta_id'] = Variable<String>(ventaId);
    map['orden'] = Variable<int>(orden);
    {
      map['medio'] = Variable<String>(
        $PagosVentaTable.$convertermedio.toSql(medio),
      );
    }
    map['monto'] = Variable<int>(monto);
    map['referencia'] = Variable<String>(referencia);
    return map;
  }

  PagosVentaCompanion toCompanion(bool nullToAbsent) {
    return PagosVentaCompanion(
      ventaId: Value(ventaId),
      orden: Value(orden),
      medio: Value(medio),
      monto: Value(monto),
      referencia: Value(referencia),
    );
  }

  factory FilaPagoVenta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaPagoVenta(
      ventaId: serializer.fromJson<String>(json['ventaId']),
      orden: serializer.fromJson<int>(json['orden']),
      medio: $PagosVentaTable.$convertermedio.fromJson(
        serializer.fromJson<String>(json['medio']),
      ),
      monto: serializer.fromJson<int>(json['monto']),
      referencia: serializer.fromJson<String>(json['referencia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ventaId': serializer.toJson<String>(ventaId),
      'orden': serializer.toJson<int>(orden),
      'medio': serializer.toJson<String>(
        $PagosVentaTable.$convertermedio.toJson(medio),
      ),
      'monto': serializer.toJson<int>(monto),
      'referencia': serializer.toJson<String>(referencia),
    };
  }

  FilaPagoVenta copyWith({
    String? ventaId,
    int? orden,
    MedioPago? medio,
    int? monto,
    String? referencia,
  }) => FilaPagoVenta(
    ventaId: ventaId ?? this.ventaId,
    orden: orden ?? this.orden,
    medio: medio ?? this.medio,
    monto: monto ?? this.monto,
    referencia: referencia ?? this.referencia,
  );
  FilaPagoVenta copyWithCompanion(PagosVentaCompanion data) {
    return FilaPagoVenta(
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      orden: data.orden.present ? data.orden.value : this.orden,
      medio: data.medio.present ? data.medio.value : this.medio,
      monto: data.monto.present ? data.monto.value : this.monto,
      referencia: data.referencia.present
          ? data.referencia.value
          : this.referencia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaPagoVenta(')
          ..write('ventaId: $ventaId, ')
          ..write('orden: $orden, ')
          ..write('medio: $medio, ')
          ..write('monto: $monto, ')
          ..write('referencia: $referencia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ventaId, orden, medio, monto, referencia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaPagoVenta &&
          other.ventaId == this.ventaId &&
          other.orden == this.orden &&
          other.medio == this.medio &&
          other.monto == this.monto &&
          other.referencia == this.referencia);
}

class PagosVentaCompanion extends UpdateCompanion<FilaPagoVenta> {
  final Value<String> ventaId;
  final Value<int> orden;
  final Value<MedioPago> medio;
  final Value<int> monto;
  final Value<String> referencia;
  final Value<int> rowid;
  const PagosVentaCompanion({
    this.ventaId = const Value.absent(),
    this.orden = const Value.absent(),
    this.medio = const Value.absent(),
    this.monto = const Value.absent(),
    this.referencia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagosVentaCompanion.insert({
    required String ventaId,
    required int orden,
    required MedioPago medio,
    required int monto,
    required String referencia,
    this.rowid = const Value.absent(),
  }) : ventaId = Value(ventaId),
       orden = Value(orden),
       medio = Value(medio),
       monto = Value(monto),
       referencia = Value(referencia);
  static Insertable<FilaPagoVenta> custom({
    Expression<String>? ventaId,
    Expression<int>? orden,
    Expression<String>? medio,
    Expression<int>? monto,
    Expression<String>? referencia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ventaId != null) 'venta_id': ventaId,
      if (orden != null) 'orden': orden,
      if (medio != null) 'medio': medio,
      if (monto != null) 'monto': monto,
      if (referencia != null) 'referencia': referencia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagosVentaCompanion copyWith({
    Value<String>? ventaId,
    Value<int>? orden,
    Value<MedioPago>? medio,
    Value<int>? monto,
    Value<String>? referencia,
    Value<int>? rowid,
  }) {
    return PagosVentaCompanion(
      ventaId: ventaId ?? this.ventaId,
      orden: orden ?? this.orden,
      medio: medio ?? this.medio,
      monto: monto ?? this.monto,
      referencia: referencia ?? this.referencia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ventaId.present) {
      map['venta_id'] = Variable<String>(ventaId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (medio.present) {
      map['medio'] = Variable<String>(
        $PagosVentaTable.$convertermedio.toSql(medio.value),
      );
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosVentaCompanion(')
          ..write('ventaId: $ventaId, ')
          ..write('orden: $orden, ')
          ..write('medio: $medio, ')
          ..write('monto: $monto, ')
          ..write('referencia: $referencia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CajasTable extends Cajas with TableInfo<$CajasTable, FilaCaja> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CajasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abiertaMeta = const VerificationMeta(
    'abierta',
  );
  @override
  late final GeneratedColumn<DateTime> abierta = GeneratedColumn<DateTime>(
    'abierta',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fondoDolaresMeta = const VerificationMeta(
    'fondoDolares',
  );
  @override
  late final GeneratedColumn<int> fondoDolares = GeneratedColumn<int>(
    'fondo_dolares',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fondoBolivaresMeta = const VerificationMeta(
    'fondoBolivares',
  );
  @override
  late final GeneratedColumn<int> fondoBolivares = GeneratedColumn<int>(
    'fondo_bolivares',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cerradaMeta = const VerificationMeta(
    'cerrada',
  );
  @override
  late final GeneratedColumn<DateTime> cerrada = GeneratedColumn<DateTime>(
    'cerrada',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contadoMeta = const VerificationMeta(
    'contado',
  );
  @override
  late final GeneratedColumn<String> contado = GeneratedColumn<String>(
    'contado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    abierta,
    fondoDolares,
    fondoBolivares,
    cerrada,
    contado,
    nota,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cajas';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaCaja> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('abierta')) {
      context.handle(
        _abiertaMeta,
        abierta.isAcceptableOrUnknown(data['abierta']!, _abiertaMeta),
      );
    } else if (isInserting) {
      context.missing(_abiertaMeta);
    }
    if (data.containsKey('fondo_dolares')) {
      context.handle(
        _fondoDolaresMeta,
        fondoDolares.isAcceptableOrUnknown(
          data['fondo_dolares']!,
          _fondoDolaresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fondoDolaresMeta);
    }
    if (data.containsKey('fondo_bolivares')) {
      context.handle(
        _fondoBolivaresMeta,
        fondoBolivares.isAcceptableOrUnknown(
          data['fondo_bolivares']!,
          _fondoBolivaresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fondoBolivaresMeta);
    }
    if (data.containsKey('cerrada')) {
      context.handle(
        _cerradaMeta,
        cerrada.isAcceptableOrUnknown(data['cerrada']!, _cerradaMeta),
      );
    }
    if (data.containsKey('contado')) {
      context.handle(
        _contadoMeta,
        contado.isAcceptableOrUnknown(data['contado']!, _contadoMeta),
      );
    } else if (isInserting) {
      context.missing(_contadoMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    } else if (isInserting) {
      context.missing(_notaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaCaja map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaCaja(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      abierta: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}abierta'],
      )!,
      fondoDolares: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fondo_dolares'],
      )!,
      fondoBolivares: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fondo_bolivares'],
      )!,
      cerrada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cerrada'],
      ),
      contado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contado'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      )!,
    );
  }

  @override
  $CajasTable createAlias(String alias) {
    return $CajasTable(attachedDatabase, alias);
  }
}

class FilaCaja extends DataClass implements Insertable<FilaCaja> {
  final String id;
  final DateTime abierta;
  final int fondoDolares;
  final int fondoBolivares;
  final DateTime? cerrada;
  final String contado;
  final String nota;
  const FilaCaja({
    required this.id,
    required this.abierta,
    required this.fondoDolares,
    required this.fondoBolivares,
    this.cerrada,
    required this.contado,
    required this.nota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['abierta'] = Variable<DateTime>(abierta);
    map['fondo_dolares'] = Variable<int>(fondoDolares);
    map['fondo_bolivares'] = Variable<int>(fondoBolivares);
    if (!nullToAbsent || cerrada != null) {
      map['cerrada'] = Variable<DateTime>(cerrada);
    }
    map['contado'] = Variable<String>(contado);
    map['nota'] = Variable<String>(nota);
    return map;
  }

  CajasCompanion toCompanion(bool nullToAbsent) {
    return CajasCompanion(
      id: Value(id),
      abierta: Value(abierta),
      fondoDolares: Value(fondoDolares),
      fondoBolivares: Value(fondoBolivares),
      cerrada: cerrada == null && nullToAbsent
          ? const Value.absent()
          : Value(cerrada),
      contado: Value(contado),
      nota: Value(nota),
    );
  }

  factory FilaCaja.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaCaja(
      id: serializer.fromJson<String>(json['id']),
      abierta: serializer.fromJson<DateTime>(json['abierta']),
      fondoDolares: serializer.fromJson<int>(json['fondoDolares']),
      fondoBolivares: serializer.fromJson<int>(json['fondoBolivares']),
      cerrada: serializer.fromJson<DateTime?>(json['cerrada']),
      contado: serializer.fromJson<String>(json['contado']),
      nota: serializer.fromJson<String>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'abierta': serializer.toJson<DateTime>(abierta),
      'fondoDolares': serializer.toJson<int>(fondoDolares),
      'fondoBolivares': serializer.toJson<int>(fondoBolivares),
      'cerrada': serializer.toJson<DateTime?>(cerrada),
      'contado': serializer.toJson<String>(contado),
      'nota': serializer.toJson<String>(nota),
    };
  }

  FilaCaja copyWith({
    String? id,
    DateTime? abierta,
    int? fondoDolares,
    int? fondoBolivares,
    Value<DateTime?> cerrada = const Value.absent(),
    String? contado,
    String? nota,
  }) => FilaCaja(
    id: id ?? this.id,
    abierta: abierta ?? this.abierta,
    fondoDolares: fondoDolares ?? this.fondoDolares,
    fondoBolivares: fondoBolivares ?? this.fondoBolivares,
    cerrada: cerrada.present ? cerrada.value : this.cerrada,
    contado: contado ?? this.contado,
    nota: nota ?? this.nota,
  );
  FilaCaja copyWithCompanion(CajasCompanion data) {
    return FilaCaja(
      id: data.id.present ? data.id.value : this.id,
      abierta: data.abierta.present ? data.abierta.value : this.abierta,
      fondoDolares: data.fondoDolares.present
          ? data.fondoDolares.value
          : this.fondoDolares,
      fondoBolivares: data.fondoBolivares.present
          ? data.fondoBolivares.value
          : this.fondoBolivares,
      cerrada: data.cerrada.present ? data.cerrada.value : this.cerrada,
      contado: data.contado.present ? data.contado.value : this.contado,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaCaja(')
          ..write('id: $id, ')
          ..write('abierta: $abierta, ')
          ..write('fondoDolares: $fondoDolares, ')
          ..write('fondoBolivares: $fondoBolivares, ')
          ..write('cerrada: $cerrada, ')
          ..write('contado: $contado, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    abierta,
    fondoDolares,
    fondoBolivares,
    cerrada,
    contado,
    nota,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaCaja &&
          other.id == this.id &&
          other.abierta == this.abierta &&
          other.fondoDolares == this.fondoDolares &&
          other.fondoBolivares == this.fondoBolivares &&
          other.cerrada == this.cerrada &&
          other.contado == this.contado &&
          other.nota == this.nota);
}

class CajasCompanion extends UpdateCompanion<FilaCaja> {
  final Value<String> id;
  final Value<DateTime> abierta;
  final Value<int> fondoDolares;
  final Value<int> fondoBolivares;
  final Value<DateTime?> cerrada;
  final Value<String> contado;
  final Value<String> nota;
  final Value<int> rowid;
  const CajasCompanion({
    this.id = const Value.absent(),
    this.abierta = const Value.absent(),
    this.fondoDolares = const Value.absent(),
    this.fondoBolivares = const Value.absent(),
    this.cerrada = const Value.absent(),
    this.contado = const Value.absent(),
    this.nota = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CajasCompanion.insert({
    required String id,
    required DateTime abierta,
    required int fondoDolares,
    required int fondoBolivares,
    this.cerrada = const Value.absent(),
    required String contado,
    required String nota,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       abierta = Value(abierta),
       fondoDolares = Value(fondoDolares),
       fondoBolivares = Value(fondoBolivares),
       contado = Value(contado),
       nota = Value(nota);
  static Insertable<FilaCaja> custom({
    Expression<String>? id,
    Expression<DateTime>? abierta,
    Expression<int>? fondoDolares,
    Expression<int>? fondoBolivares,
    Expression<DateTime>? cerrada,
    Expression<String>? contado,
    Expression<String>? nota,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (abierta != null) 'abierta': abierta,
      if (fondoDolares != null) 'fondo_dolares': fondoDolares,
      if (fondoBolivares != null) 'fondo_bolivares': fondoBolivares,
      if (cerrada != null) 'cerrada': cerrada,
      if (contado != null) 'contado': contado,
      if (nota != null) 'nota': nota,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CajasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? abierta,
    Value<int>? fondoDolares,
    Value<int>? fondoBolivares,
    Value<DateTime?>? cerrada,
    Value<String>? contado,
    Value<String>? nota,
    Value<int>? rowid,
  }) {
    return CajasCompanion(
      id: id ?? this.id,
      abierta: abierta ?? this.abierta,
      fondoDolares: fondoDolares ?? this.fondoDolares,
      fondoBolivares: fondoBolivares ?? this.fondoBolivares,
      cerrada: cerrada ?? this.cerrada,
      contado: contado ?? this.contado,
      nota: nota ?? this.nota,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (abierta.present) {
      map['abierta'] = Variable<DateTime>(abierta.value);
    }
    if (fondoDolares.present) {
      map['fondo_dolares'] = Variable<int>(fondoDolares.value);
    }
    if (fondoBolivares.present) {
      map['fondo_bolivares'] = Variable<int>(fondoBolivares.value);
    }
    if (cerrada.present) {
      map['cerrada'] = Variable<DateTime>(cerrada.value);
    }
    if (contado.present) {
      map['contado'] = Variable<String>(contado.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CajasCompanion(')
          ..write('id: $id, ')
          ..write('abierta: $abierta, ')
          ..write('fondoDolares: $fondoDolares, ')
          ..write('fondoBolivares: $fondoBolivares, ')
          ..write('cerrada: $cerrada, ')
          ..write('contado: $contado, ')
          ..write('nota: $nota, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GastosTable extends Gastos with TableInfo<$GastosTable, FilaGasto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoriaGasto, String>
  categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CategoriaGasto>($GastosTable.$convertercategoria);
  @override
  late final GeneratedColumnWithTypeConverter<MedioPago, String> medio =
      GeneratedColumn<String>(
        'medio',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MedioPago>($GastosTable.$convertermedio);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tasaMeta = const VerificationMeta('tasa');
  @override
  late final GeneratedColumn<int> tasa = GeneratedColumn<int>(
    'tasa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    categoria,
    medio,
    monto,
    tasa,
    nota,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaGasto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('tasa')) {
      context.handle(
        _tasaMeta,
        tasa.isAcceptableOrUnknown(data['tasa']!, _tasaMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    } else if (isInserting) {
      context.missing(_notaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaGasto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaGasto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      categoria: $GastosTable.$convertercategoria.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}categoria'],
        )!,
      ),
      medio: $GastosTable.$convertermedio.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}medio'],
        )!,
      ),
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      tasa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tasa'],
      ),
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      )!,
    );
  }

  @override
  $GastosTable createAlias(String alias) {
    return $GastosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoriaGasto, String, String>
  $convertercategoria = const EnumNameConverter<CategoriaGasto>(
    CategoriaGasto.values,
  );
  static JsonTypeConverter2<MedioPago, String, String> $convertermedio =
      const EnumNameConverter<MedioPago>(MedioPago.values);
}

class FilaGasto extends DataClass implements Insertable<FilaGasto> {
  final String id;
  final DateTime fecha;
  final CategoriaGasto categoria;
  final MedioPago medio;
  final int monto;
  final int? tasa;
  final String nota;
  const FilaGasto({
    required this.id,
    required this.fecha,
    required this.categoria,
    required this.medio,
    required this.monto,
    this.tasa,
    required this.nota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    {
      map['categoria'] = Variable<String>(
        $GastosTable.$convertercategoria.toSql(categoria),
      );
    }
    {
      map['medio'] = Variable<String>(
        $GastosTable.$convertermedio.toSql(medio),
      );
    }
    map['monto'] = Variable<int>(monto);
    if (!nullToAbsent || tasa != null) {
      map['tasa'] = Variable<int>(tasa);
    }
    map['nota'] = Variable<String>(nota);
    return map;
  }

  GastosCompanion toCompanion(bool nullToAbsent) {
    return GastosCompanion(
      id: Value(id),
      fecha: Value(fecha),
      categoria: Value(categoria),
      medio: Value(medio),
      monto: Value(monto),
      tasa: tasa == null && nullToAbsent ? const Value.absent() : Value(tasa),
      nota: Value(nota),
    );
  }

  factory FilaGasto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaGasto(
      id: serializer.fromJson<String>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      categoria: $GastosTable.$convertercategoria.fromJson(
        serializer.fromJson<String>(json['categoria']),
      ),
      medio: $GastosTable.$convertermedio.fromJson(
        serializer.fromJson<String>(json['medio']),
      ),
      monto: serializer.fromJson<int>(json['monto']),
      tasa: serializer.fromJson<int?>(json['tasa']),
      nota: serializer.fromJson<String>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'categoria': serializer.toJson<String>(
        $GastosTable.$convertercategoria.toJson(categoria),
      ),
      'medio': serializer.toJson<String>(
        $GastosTable.$convertermedio.toJson(medio),
      ),
      'monto': serializer.toJson<int>(monto),
      'tasa': serializer.toJson<int?>(tasa),
      'nota': serializer.toJson<String>(nota),
    };
  }

  FilaGasto copyWith({
    String? id,
    DateTime? fecha,
    CategoriaGasto? categoria,
    MedioPago? medio,
    int? monto,
    Value<int?> tasa = const Value.absent(),
    String? nota,
  }) => FilaGasto(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    categoria: categoria ?? this.categoria,
    medio: medio ?? this.medio,
    monto: monto ?? this.monto,
    tasa: tasa.present ? tasa.value : this.tasa,
    nota: nota ?? this.nota,
  );
  FilaGasto copyWithCompanion(GastosCompanion data) {
    return FilaGasto(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      medio: data.medio.present ? data.medio.value : this.medio,
      monto: data.monto.present ? data.monto.value : this.monto,
      tasa: data.tasa.present ? data.tasa.value : this.tasa,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaGasto(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('categoria: $categoria, ')
          ..write('medio: $medio, ')
          ..write('monto: $monto, ')
          ..write('tasa: $tasa, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fecha, categoria, medio, monto, tasa, nota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaGasto &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.categoria == this.categoria &&
          other.medio == this.medio &&
          other.monto == this.monto &&
          other.tasa == this.tasa &&
          other.nota == this.nota);
}

class GastosCompanion extends UpdateCompanion<FilaGasto> {
  final Value<String> id;
  final Value<DateTime> fecha;
  final Value<CategoriaGasto> categoria;
  final Value<MedioPago> medio;
  final Value<int> monto;
  final Value<int?> tasa;
  final Value<String> nota;
  final Value<int> rowid;
  const GastosCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.categoria = const Value.absent(),
    this.medio = const Value.absent(),
    this.monto = const Value.absent(),
    this.tasa = const Value.absent(),
    this.nota = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GastosCompanion.insert({
    required String id,
    required DateTime fecha,
    required CategoriaGasto categoria,
    required MedioPago medio,
    required int monto,
    this.tasa = const Value.absent(),
    required String nota,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fecha = Value(fecha),
       categoria = Value(categoria),
       medio = Value(medio),
       monto = Value(monto),
       nota = Value(nota);
  static Insertable<FilaGasto> custom({
    Expression<String>? id,
    Expression<DateTime>? fecha,
    Expression<String>? categoria,
    Expression<String>? medio,
    Expression<int>? monto,
    Expression<int>? tasa,
    Expression<String>? nota,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (categoria != null) 'categoria': categoria,
      if (medio != null) 'medio': medio,
      if (monto != null) 'monto': monto,
      if (tasa != null) 'tasa': tasa,
      if (nota != null) 'nota': nota,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GastosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? fecha,
    Value<CategoriaGasto>? categoria,
    Value<MedioPago>? medio,
    Value<int>? monto,
    Value<int?>? tasa,
    Value<String>? nota,
    Value<int>? rowid,
  }) {
    return GastosCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      categoria: categoria ?? this.categoria,
      medio: medio ?? this.medio,
      monto: monto ?? this.monto,
      tasa: tasa ?? this.tasa,
      nota: nota ?? this.nota,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(
        $GastosTable.$convertercategoria.toSql(categoria.value),
      );
    }
    if (medio.present) {
      map['medio'] = Variable<String>(
        $GastosTable.$convertermedio.toSql(medio.value),
      );
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (tasa.present) {
      map['tasa'] = Variable<int>(tasa.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('categoria: $categoria, ')
          ..write('medio: $medio, ')
          ..write('monto: $monto, ')
          ..write('tasa: $tasa, ')
          ..write('nota: $nota, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDatos extends GeneratedDatabase {
  _$BaseDatos(QueryExecutor e) : super(e);
  $BaseDatosManager get managers => $BaseDatosManager(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $LotesMarcaTable lotesMarca = $LotesMarcaTable(this);
  late final $PresentacionesTable presentaciones = $PresentacionesTable(this);
  late final $ProveedoresTable proveedores = $ProveedoresTable(this);
  late final $IncidenciasTable incidencias = $IncidenciasTable(this);
  late final $MovimientosTable movimientos = $MovimientosTable(this);
  late final $ComprasTable compras = $ComprasTable(this);
  late final $LineasCompraTable lineasCompra = $LineasCompraTable(this);
  late final $PagosTable pagos = $PagosTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $PagosVentaTable pagosVenta = $PagosVentaTable(this);
  late final $CajasTable cajas = $CajasTable(this);
  late final $GastosTable gastos = $GastosTable(this);
  late final Index presentacionesCodigo = Index(
    'presentaciones_codigo',
    'CREATE INDEX presentaciones_codigo ON presentaciones (codigo)',
  );
  late final Index movimientosFecha = Index(
    'movimientos_fecha',
    'CREATE INDEX movimientos_fecha ON movimientos (fecha)',
  );
  late final Index movimientosProducto = Index(
    'movimientos_producto',
    'CREATE INDEX movimientos_producto ON movimientos (producto_id)',
  );
  late final Index ventasFecha = Index(
    'ventas_fecha',
    'CREATE INDEX ventas_fecha ON ventas (fecha)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productos,
    lotesMarca,
    presentaciones,
    proveedores,
    incidencias,
    movimientos,
    compras,
    lineasCompra,
    pagos,
    ventas,
    pagosVenta,
    cajas,
    gastos,
    presentacionesCodigo,
    movimientosFecha,
    movimientosProducto,
    ventasFecha,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'productos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lotes_marca', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'productos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('presentaciones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'compras',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lineas_compra', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'compras',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pagos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ventas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pagos_venta', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProductosTableCreateCompanionBuilder = ProductosCompanion Function({
  required String id,
  required String nombre,
  required String nombreClave,
  required Categoria categoria,
  required FormaConteo forma,
  required int minimo,
  Value<String?> imagenId,
  Value<int> rowid,
});
typedef $$ProductosTableUpdateCompanionBuilder = ProductosCompanion Function({
  Value<String> id,
  Value<String> nombre,
  Value<String> nombreClave,
  Value<Categoria> categoria,
  Value<FormaConteo> forma,
  Value<int> minimo,
  Value<String?> imagenId,
  Value<int> rowid,
});

final class $$ProductosTableReferences
    extends BaseReferences<_$BaseDatos, $ProductosTable, FilaProducto> {
  $$ProductosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LotesMarcaTable, List<FilaLoteMarca>>
  _lotesMarcaRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.lotesMarca,
    aliasName: 'productos__id__lotes_marca__producto_id',
  );

  $$LotesMarcaTableProcessedTableManager get lotesMarcaRefs {
    final manager = $$LotesMarcaTableTableManager(
      $_db,
      $_db.lotesMarca,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lotesMarcaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PresentacionesTable, List<FilaPresentacion>>
  _presentacionesRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.presentaciones,
    aliasName: 'productos__id__presentaciones__producto_id',
  );

  $$PresentacionesTableProcessedTableManager get presentacionesRefs {
    final manager = $$PresentacionesTableTableManager(
      $_db,
      $_db.presentaciones,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_presentacionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductosTableFilterComposer
    extends Composer<_$BaseDatos, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreClave => $composableBuilder(
    column: $table.nombreClave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Categoria, Categoria, String> get categoria =>
      $composableBuilder(
        column: $table.categoria,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<FormaConteo, FormaConteo, String> get forma =>
      $composableBuilder(
        column: $table.forma,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get minimo => $composableBuilder(
    column: $table.minimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagenId => $composableBuilder(
    column: $table.imagenId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lotesMarcaRefs(
    Expression<bool> Function($$LotesMarcaTableFilterComposer f) f,
  ) {
    final $$LotesMarcaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lotesMarca,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesMarcaTableFilterComposer(
            $db: $db,
            $table: $db.lotesMarca,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> presentacionesRefs(
    Expression<bool> Function($$PresentacionesTableFilterComposer f) f,
  ) {
    final $$PresentacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.presentaciones,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresentacionesTableFilterComposer(
            $db: $db,
            $table: $db.presentaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableOrderingComposer
    extends Composer<_$BaseDatos, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreClave => $composableBuilder(
    column: $table.nombreClave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forma => $composableBuilder(
    column: $table.forma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimo => $composableBuilder(
    column: $table.minimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagenId => $composableBuilder(
    column: $table.imagenId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$BaseDatos, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get nombreClave => $composableBuilder(
    column: $table.nombreClave,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Categoria, String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormaConteo, String> get forma =>
      $composableBuilder(column: $table.forma, builder: (column) => column);

  GeneratedColumn<int> get minimo =>
      $composableBuilder(column: $table.minimo, builder: (column) => column);

  GeneratedColumn<String> get imagenId =>
      $composableBuilder(column: $table.imagenId, builder: (column) => column);

  Expression<T> lotesMarcaRefs<T extends Object>(
    Expression<T> Function($$LotesMarcaTableAnnotationComposer a) f,
  ) {
    final $$LotesMarcaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lotesMarca,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesMarcaTableAnnotationComposer(
            $db: $db,
            $table: $db.lotesMarca,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> presentacionesRefs<T extends Object>(
    Expression<T> Function($$PresentacionesTableAnnotationComposer a) f,
  ) {
    final $$PresentacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.presentaciones,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PresentacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.presentaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $ProductosTable,
          FilaProducto,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (FilaProducto, $$ProductosTableReferences),
          FilaProducto,
          PrefetchHooks Function({bool lotesMarcaRefs, bool presentacionesRefs})
        > {
  $$ProductosTableTableManager(_$BaseDatos db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> nombreClave = const Value.absent(),
                Value<Categoria> categoria = const Value.absent(),
                Value<FormaConteo> forma = const Value.absent(),
                Value<int> minimo = const Value.absent(),
                Value<String?> imagenId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                nombre: nombre,
                nombreClave: nombreClave,
                categoria: categoria,
                forma: forma,
                minimo: minimo,
                imagenId: imagenId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                required String nombreClave,
                required Categoria categoria,
                required FormaConteo forma,
                required int minimo,
                Value<String?> imagenId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion.insert(
                id: id,
                nombre: nombre,
                nombreClave: nombreClave,
                categoria: categoria,
                forma: forma,
                minimo: minimo,
                imagenId: imagenId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductosTable, FilaProducto>(table),
                  $$ProductosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({lotesMarcaRefs = false, presentacionesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lotesMarcaRefs) db.lotesMarca,
                    if (presentacionesRefs) db.presentaciones,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lotesMarcaRefs)
                        await $_getPrefetchedDataByColumns<
                          FilaProducto,
                          $ProductosTable,
                          FilaLoteMarca,
                          $LotesMarcaTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._lotesMarcaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).lotesMarcaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'producto_id',
                          typedResults: items,
                        ),
                      if (presentacionesRefs)
                        await $_getPrefetchedDataByColumns<
                          FilaProducto,
                          $ProductosTable,
                          FilaPresentacion,
                          $PresentacionesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._presentacionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).presentacionesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'producto_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $ProductosTable,
      FilaProducto,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (FilaProducto, $$ProductosTableReferences),
      FilaProducto,
      PrefetchHooks Function({bool lotesMarcaRefs, bool presentacionesRefs})
    >;
typedef $$LotesMarcaTableCreateCompanionBuilder = LotesMarcaCompanion Function({
  required String productoId,
  required int orden,
  required String marca,
  required String proveedor,
  required int piezas,
  required bool piezaAbierta,
  required int cantidad,
  Value<int?> precio,
  Value<int?> costo,
  Value<int> rowid,
});
typedef $$LotesMarcaTableUpdateCompanionBuilder = LotesMarcaCompanion Function({
  Value<String> productoId,
  Value<int> orden,
  Value<String> marca,
  Value<String> proveedor,
  Value<int> piezas,
  Value<bool> piezaAbierta,
  Value<int> cantidad,
  Value<int?> precio,
  Value<int?> costo,
  Value<int> rowid,
});

final class $$LotesMarcaTableReferences
    extends BaseReferences<_$BaseDatos, $LotesMarcaTable, FilaLoteMarca> {
  $$LotesMarcaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductosTable _productoIdTable(_$BaseDatos db) =>
      db.productos.createAlias('lotes_marca__producto_id__productos__id');

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<String>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LotesMarcaTableFilterComposer
    extends Composer<_$BaseDatos, $LotesMarcaTable> {
  $$LotesMarcaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get piezaAbierta => $composableBuilder(
    column: $table.piezaAbierta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LotesMarcaTableOrderingComposer
    extends Composer<_$BaseDatos, $LotesMarcaTable> {
  $$LotesMarcaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get piezaAbierta => $composableBuilder(
    column: $table.piezaAbierta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LotesMarcaTableAnnotationComposer
    extends Composer<_$BaseDatos, $LotesMarcaTable> {
  $$LotesMarcaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<int> get piezas =>
      $composableBuilder(column: $table.piezas, builder: (column) => column);

  GeneratedColumn<bool> get piezaAbierta => $composableBuilder(
    column: $table.piezaAbierta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<int> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LotesMarcaTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $LotesMarcaTable,
          FilaLoteMarca,
          $$LotesMarcaTableFilterComposer,
          $$LotesMarcaTableOrderingComposer,
          $$LotesMarcaTableAnnotationComposer,
          $$LotesMarcaTableCreateCompanionBuilder,
          $$LotesMarcaTableUpdateCompanionBuilder,
          (FilaLoteMarca, $$LotesMarcaTableReferences),
          FilaLoteMarca,
          PrefetchHooks Function({bool productoId})
        > {
  $$LotesMarcaTableTableManager(_$BaseDatos db, $LotesMarcaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesMarcaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesMarcaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesMarcaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productoId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> proveedor = const Value.absent(),
                Value<int> piezas = const Value.absent(),
                Value<bool> piezaAbierta = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int?> precio = const Value.absent(),
                Value<int?> costo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotesMarcaCompanion(
                productoId: productoId,
                orden: orden,
                marca: marca,
                proveedor: proveedor,
                piezas: piezas,
                piezaAbierta: piezaAbierta,
                cantidad: cantidad,
                precio: precio,
                costo: costo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productoId,
                required int orden,
                required String marca,
                required String proveedor,
                required int piezas,
                required bool piezaAbierta,
                required int cantidad,
                Value<int?> precio = const Value.absent(),
                Value<int?> costo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotesMarcaCompanion.insert(
                productoId: productoId,
                orden: orden,
                marca: marca,
                proveedor: proveedor,
                piezas: piezas,
                piezaAbierta: piezaAbierta,
                cantidad: cantidad,
                precio: precio,
                costo: costo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LotesMarcaTable, FilaLoteMarca>(table),
                  $$LotesMarcaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productoId,
                        referencedTable: $$LotesMarcaTableReferences
                            ._productoIdTable(db),
                        referencedColumn: $$LotesMarcaTableReferences
                            ._productoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LotesMarcaTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $LotesMarcaTable,
      FilaLoteMarca,
      $$LotesMarcaTableFilterComposer,
      $$LotesMarcaTableOrderingComposer,
      $$LotesMarcaTableAnnotationComposer,
      $$LotesMarcaTableCreateCompanionBuilder,
      $$LotesMarcaTableUpdateCompanionBuilder,
      (FilaLoteMarca, $$LotesMarcaTableReferences),
      FilaLoteMarca,
      PrefetchHooks Function({bool productoId})
    >;
typedef $$PresentacionesTableCreateCompanionBuilder =
    PresentacionesCompanion Function({
      required String productoId,
      required int orden,
      required String nombre,
      required int factor,
      required int precio,
      required String codigo,
      required bool predeterminada,
      Value<int> rowid,
    });
typedef $$PresentacionesTableUpdateCompanionBuilder =
    PresentacionesCompanion Function({
      Value<String> productoId,
      Value<int> orden,
      Value<String> nombre,
      Value<int> factor,
      Value<int> precio,
      Value<String> codigo,
      Value<bool> predeterminada,
      Value<int> rowid,
    });

final class $$PresentacionesTableReferences
    extends
        BaseReferences<_$BaseDatos, $PresentacionesTable, FilaPresentacion> {
  $$PresentacionesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductosTable _productoIdTable(_$BaseDatos db) =>
      db.productos.createAlias('presentaciones__producto_id__productos__id');

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<String>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PresentacionesTableFilterComposer
    extends Composer<_$BaseDatos, $PresentacionesTable> {
  $$PresentacionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get predeterminada => $composableBuilder(
    column: $table.predeterminada,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PresentacionesTableOrderingComposer
    extends Composer<_$BaseDatos, $PresentacionesTable> {
  $$PresentacionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precio => $composableBuilder(
    column: $table.precio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get predeterminada => $composableBuilder(
    column: $table.predeterminada,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PresentacionesTableAnnotationComposer
    extends Composer<_$BaseDatos, $PresentacionesTable> {
  $$PresentacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get factor =>
      $composableBuilder(column: $table.factor, builder: (column) => column);

  GeneratedColumn<int> get precio =>
      $composableBuilder(column: $table.precio, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<bool> get predeterminada => $composableBuilder(
    column: $table.predeterminada,
    builder: (column) => column,
  );

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PresentacionesTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $PresentacionesTable,
          FilaPresentacion,
          $$PresentacionesTableFilterComposer,
          $$PresentacionesTableOrderingComposer,
          $$PresentacionesTableAnnotationComposer,
          $$PresentacionesTableCreateCompanionBuilder,
          $$PresentacionesTableUpdateCompanionBuilder,
          (FilaPresentacion, $$PresentacionesTableReferences),
          FilaPresentacion,
          PrefetchHooks Function({bool productoId})
        > {
  $$PresentacionesTableTableManager(_$BaseDatos db, $PresentacionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresentacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresentacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresentacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productoId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> factor = const Value.absent(),
                Value<int> precio = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<bool> predeterminada = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PresentacionesCompanion(
                productoId: productoId,
                orden: orden,
                nombre: nombre,
                factor: factor,
                precio: precio,
                codigo: codigo,
                predeterminada: predeterminada,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productoId,
                required int orden,
                required String nombre,
                required int factor,
                required int precio,
                required String codigo,
                required bool predeterminada,
                Value<int> rowid = const Value.absent(),
              }) => PresentacionesCompanion.insert(
                productoId: productoId,
                orden: orden,
                nombre: nombre,
                factor: factor,
                precio: precio,
                codigo: codigo,
                predeterminada: predeterminada,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PresentacionesTable, FilaPresentacion>(table),
                  $$PresentacionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productoId,
                        referencedTable: $$PresentacionesTableReferences
                            ._productoIdTable(db),
                        referencedColumn: $$PresentacionesTableReferences
                            ._productoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PresentacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $PresentacionesTable,
      FilaPresentacion,
      $$PresentacionesTableFilterComposer,
      $$PresentacionesTableOrderingComposer,
      $$PresentacionesTableAnnotationComposer,
      $$PresentacionesTableCreateCompanionBuilder,
      $$PresentacionesTableUpdateCompanionBuilder,
      (FilaPresentacion, $$PresentacionesTableReferences),
      FilaPresentacion,
      PrefetchHooks Function({bool productoId})
    >;
typedef $$ProveedoresTableCreateCompanionBuilder =
    ProveedoresCompanion Function({
      required String id,
      required String nombre,
      required String nombreClave,
      required String rif,
      required String telefono,
      required String contacto,
      required String notas,
      Value<int> rowid,
    });
typedef $$ProveedoresTableUpdateCompanionBuilder =
    ProveedoresCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String> nombreClave,
      Value<String> rif,
      Value<String> telefono,
      Value<String> contacto,
      Value<String> notas,
      Value<int> rowid,
    });

class $$ProveedoresTableFilterComposer
    extends Composer<_$BaseDatos, $ProveedoresTable> {
  $$ProveedoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreClave => $composableBuilder(
    column: $table.nombreClave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rif => $composableBuilder(
    column: $table.rif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contacto => $composableBuilder(
    column: $table.contacto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProveedoresTableOrderingComposer
    extends Composer<_$BaseDatos, $ProveedoresTable> {
  $$ProveedoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreClave => $composableBuilder(
    column: $table.nombreClave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rif => $composableBuilder(
    column: $table.rif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contacto => $composableBuilder(
    column: $table.contacto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProveedoresTableAnnotationComposer
    extends Composer<_$BaseDatos, $ProveedoresTable> {
  $$ProveedoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get nombreClave => $composableBuilder(
    column: $table.nombreClave,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rif =>
      $composableBuilder(column: $table.rif, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get contacto =>
      $composableBuilder(column: $table.contacto, builder: (column) => column);

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);
}

class $$ProveedoresTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $ProveedoresTable,
          FilaProveedor,
          $$ProveedoresTableFilterComposer,
          $$ProveedoresTableOrderingComposer,
          $$ProveedoresTableAnnotationComposer,
          $$ProveedoresTableCreateCompanionBuilder,
          $$ProveedoresTableUpdateCompanionBuilder,
          (
            FilaProveedor,
            BaseReferences<_$BaseDatos, $ProveedoresTable, FilaProveedor>,
          ),
          FilaProveedor,
          PrefetchHooks Function()
        > {
  $$ProveedoresTableTableManager(_$BaseDatos db, $ProveedoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProveedoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProveedoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProveedoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> nombreClave = const Value.absent(),
                Value<String> rif = const Value.absent(),
                Value<String> telefono = const Value.absent(),
                Value<String> contacto = const Value.absent(),
                Value<String> notas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProveedoresCompanion(
                id: id,
                nombre: nombre,
                nombreClave: nombreClave,
                rif: rif,
                telefono: telefono,
                contacto: contacto,
                notas: notas,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                required String nombreClave,
                required String rif,
                required String telefono,
                required String contacto,
                required String notas,
                Value<int> rowid = const Value.absent(),
              }) => ProveedoresCompanion.insert(
                id: id,
                nombre: nombre,
                nombreClave: nombreClave,
                rif: rif,
                telefono: telefono,
                contacto: contacto,
                notas: notas,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProveedoresTable, FilaProveedor>(table),
                  BaseReferences<_$BaseDatos, $ProveedoresTable, FilaProveedor>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProveedoresTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $ProveedoresTable,
      FilaProveedor,
      $$ProveedoresTableFilterComposer,
      $$ProveedoresTableOrderingComposer,
      $$ProveedoresTableAnnotationComposer,
      $$ProveedoresTableCreateCompanionBuilder,
      $$ProveedoresTableUpdateCompanionBuilder,
      (
        FilaProveedor,
        BaseReferences<_$BaseDatos, $ProveedoresTable, FilaProveedor>,
      ),
      FilaProveedor,
      PrefetchHooks Function()
    >;
typedef $$IncidenciasTableCreateCompanionBuilder =
    IncidenciasCompanion Function({
      required String id,
      required DateTime fecha,
      required String proveedor,
      required String productoId,
      required String producto,
      required FormaConteo forma,
      required String marca,
      required TipoIncidencia tipo,
      required int piezas,
      required int cantidad,
      required String nota,
      required bool sacada,
      Value<RespuestaProveedor?> respuesta,
      Value<int> rowid,
    });
typedef $$IncidenciasTableUpdateCompanionBuilder =
    IncidenciasCompanion Function({
      Value<String> id,
      Value<DateTime> fecha,
      Value<String> proveedor,
      Value<String> productoId,
      Value<String> producto,
      Value<FormaConteo> forma,
      Value<String> marca,
      Value<TipoIncidencia> tipo,
      Value<int> piezas,
      Value<int> cantidad,
      Value<String> nota,
      Value<bool> sacada,
      Value<RespuestaProveedor?> respuesta,
      Value<int> rowid,
    });

class $$IncidenciasTableFilterComposer
    extends Composer<_$BaseDatos, $IncidenciasTable> {
  $$IncidenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FormaConteo, FormaConteo, String> get forma =>
      $composableBuilder(
        column: $table.forma,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoIncidencia, TipoIncidencia, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sacada => $composableBuilder(
    column: $table.sacada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    RespuestaProveedor?,
    RespuestaProveedor,
    String
  >
  get respuesta => $composableBuilder(
    column: $table.respuesta,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$IncidenciasTableOrderingComposer
    extends Composer<_$BaseDatos, $IncidenciasTable> {
  $$IncidenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forma => $composableBuilder(
    column: $table.forma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sacada => $composableBuilder(
    column: $table.sacada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respuesta => $composableBuilder(
    column: $table.respuesta,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncidenciasTableAnnotationComposer
    extends Composer<_$BaseDatos, $IncidenciasTable> {
  $$IncidenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormaConteo, String> get forma =>
      $composableBuilder(column: $table.forma, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoIncidencia, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get piezas =>
      $composableBuilder(column: $table.piezas, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<bool> get sacada =>
      $composableBuilder(column: $table.sacada, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RespuestaProveedor?, String> get respuesta =>
      $composableBuilder(column: $table.respuesta, builder: (column) => column);
}

class $$IncidenciasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $IncidenciasTable,
          FilaIncidencia,
          $$IncidenciasTableFilterComposer,
          $$IncidenciasTableOrderingComposer,
          $$IncidenciasTableAnnotationComposer,
          $$IncidenciasTableCreateCompanionBuilder,
          $$IncidenciasTableUpdateCompanionBuilder,
          (
            FilaIncidencia,
            BaseReferences<_$BaseDatos, $IncidenciasTable, FilaIncidencia>,
          ),
          FilaIncidencia,
          PrefetchHooks Function()
        > {
  $$IncidenciasTableTableManager(_$BaseDatos db, $IncidenciasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncidenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncidenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncidenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> proveedor = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<String> producto = const Value.absent(),
                Value<FormaConteo> forma = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<TipoIncidencia> tipo = const Value.absent(),
                Value<int> piezas = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<String> nota = const Value.absent(),
                Value<bool> sacada = const Value.absent(),
                Value<RespuestaProveedor?> respuesta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncidenciasCompanion(
                id: id,
                fecha: fecha,
                proveedor: proveedor,
                productoId: productoId,
                producto: producto,
                forma: forma,
                marca: marca,
                tipo: tipo,
                piezas: piezas,
                cantidad: cantidad,
                nota: nota,
                sacada: sacada,
                respuesta: respuesta,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime fecha,
                required String proveedor,
                required String productoId,
                required String producto,
                required FormaConteo forma,
                required String marca,
                required TipoIncidencia tipo,
                required int piezas,
                required int cantidad,
                required String nota,
                required bool sacada,
                Value<RespuestaProveedor?> respuesta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncidenciasCompanion.insert(
                id: id,
                fecha: fecha,
                proveedor: proveedor,
                productoId: productoId,
                producto: producto,
                forma: forma,
                marca: marca,
                tipo: tipo,
                piezas: piezas,
                cantidad: cantidad,
                nota: nota,
                sacada: sacada,
                respuesta: respuesta,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IncidenciasTable, FilaIncidencia>(table),
                  BaseReferences<
                    _$BaseDatos,
                    $IncidenciasTable,
                    FilaIncidencia
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncidenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $IncidenciasTable,
      FilaIncidencia,
      $$IncidenciasTableFilterComposer,
      $$IncidenciasTableOrderingComposer,
      $$IncidenciasTableAnnotationComposer,
      $$IncidenciasTableCreateCompanionBuilder,
      $$IncidenciasTableUpdateCompanionBuilder,
      (
        FilaIncidencia,
        BaseReferences<_$BaseDatos, $IncidenciasTable, FilaIncidencia>,
      ),
      FilaIncidencia,
      PrefetchHooks Function()
    >;
typedef $$MovimientosTableCreateCompanionBuilder =
    MovimientosCompanion Function({
      required String id,
      required DateTime fecha,
      required TipoMovimiento tipo,
      required String productoId,
      required String producto,
      required FormaConteo forma,
      required String marca,
      required String proveedor,
      required int piezas,
      required int cantidad,
      Value<int?> importe,
      Value<int?> costo,
      required bool abrioPieza,
      required bool anulada,
      Value<int?> tasa,
      required String nota,
      Value<String?> origenId,
      Value<String?> ventaId,
      Value<int> rowid,
    });
typedef $$MovimientosTableUpdateCompanionBuilder =
    MovimientosCompanion Function({
      Value<String> id,
      Value<DateTime> fecha,
      Value<TipoMovimiento> tipo,
      Value<String> productoId,
      Value<String> producto,
      Value<FormaConteo> forma,
      Value<String> marca,
      Value<String> proveedor,
      Value<int> piezas,
      Value<int> cantidad,
      Value<int?> importe,
      Value<int?> costo,
      Value<bool> abrioPieza,
      Value<bool> anulada,
      Value<int?> tasa,
      Value<String> nota,
      Value<String?> origenId,
      Value<String?> ventaId,
      Value<int> rowid,
    });

class $$MovimientosTableFilterComposer
    extends Composer<_$BaseDatos, $MovimientosTable> {
  $$MovimientosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoMovimiento, TipoMovimiento, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FormaConteo, FormaConteo, String> get forma =>
      $composableBuilder(
        column: $table.forma,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importe => $composableBuilder(
    column: $table.importe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get abrioPieza => $composableBuilder(
    column: $table.abrioPieza,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get anulada => $composableBuilder(
    column: $table.anulada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origenId => $composableBuilder(
    column: $table.origenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ventaId => $composableBuilder(
    column: $table.ventaId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovimientosTableOrderingComposer
    extends Composer<_$BaseDatos, $MovimientosTable> {
  $$MovimientosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forma => $composableBuilder(
    column: $table.forma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importe => $composableBuilder(
    column: $table.importe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get abrioPieza => $composableBuilder(
    column: $table.abrioPieza,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get anulada => $composableBuilder(
    column: $table.anulada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origenId => $composableBuilder(
    column: $table.origenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ventaId => $composableBuilder(
    column: $table.ventaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovimientosTableAnnotationComposer
    extends Composer<_$BaseDatos, $MovimientosTable> {
  $$MovimientosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoMovimiento, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormaConteo, String> get forma =>
      $composableBuilder(column: $table.forma, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<int> get piezas =>
      $composableBuilder(column: $table.piezas, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get importe =>
      $composableBuilder(column: $table.importe, builder: (column) => column);

  GeneratedColumn<int> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  GeneratedColumn<bool> get abrioPieza => $composableBuilder(
    column: $table.abrioPieza,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get anulada =>
      $composableBuilder(column: $table.anulada, builder: (column) => column);

  GeneratedColumn<int> get tasa =>
      $composableBuilder(column: $table.tasa, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<String> get origenId =>
      $composableBuilder(column: $table.origenId, builder: (column) => column);

  GeneratedColumn<String> get ventaId =>
      $composableBuilder(column: $table.ventaId, builder: (column) => column);
}

class $$MovimientosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $MovimientosTable,
          FilaMovimiento,
          $$MovimientosTableFilterComposer,
          $$MovimientosTableOrderingComposer,
          $$MovimientosTableAnnotationComposer,
          $$MovimientosTableCreateCompanionBuilder,
          $$MovimientosTableUpdateCompanionBuilder,
          (
            FilaMovimiento,
            BaseReferences<_$BaseDatos, $MovimientosTable, FilaMovimiento>,
          ),
          FilaMovimiento,
          PrefetchHooks Function()
        > {
  $$MovimientosTableTableManager(_$BaseDatos db, $MovimientosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<TipoMovimiento> tipo = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<String> producto = const Value.absent(),
                Value<FormaConteo> forma = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> proveedor = const Value.absent(),
                Value<int> piezas = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int?> importe = const Value.absent(),
                Value<int?> costo = const Value.absent(),
                Value<bool> abrioPieza = const Value.absent(),
                Value<bool> anulada = const Value.absent(),
                Value<int?> tasa = const Value.absent(),
                Value<String> nota = const Value.absent(),
                Value<String?> origenId = const Value.absent(),
                Value<String?> ventaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosCompanion(
                id: id,
                fecha: fecha,
                tipo: tipo,
                productoId: productoId,
                producto: producto,
                forma: forma,
                marca: marca,
                proveedor: proveedor,
                piezas: piezas,
                cantidad: cantidad,
                importe: importe,
                costo: costo,
                abrioPieza: abrioPieza,
                anulada: anulada,
                tasa: tasa,
                nota: nota,
                origenId: origenId,
                ventaId: ventaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime fecha,
                required TipoMovimiento tipo,
                required String productoId,
                required String producto,
                required FormaConteo forma,
                required String marca,
                required String proveedor,
                required int piezas,
                required int cantidad,
                Value<int?> importe = const Value.absent(),
                Value<int?> costo = const Value.absent(),
                required bool abrioPieza,
                required bool anulada,
                Value<int?> tasa = const Value.absent(),
                required String nota,
                Value<String?> origenId = const Value.absent(),
                Value<String?> ventaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosCompanion.insert(
                id: id,
                fecha: fecha,
                tipo: tipo,
                productoId: productoId,
                producto: producto,
                forma: forma,
                marca: marca,
                proveedor: proveedor,
                piezas: piezas,
                cantidad: cantidad,
                importe: importe,
                costo: costo,
                abrioPieza: abrioPieza,
                anulada: anulada,
                tasa: tasa,
                nota: nota,
                origenId: origenId,
                ventaId: ventaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovimientosTable, FilaMovimiento>(table),
                  BaseReferences<
                    _$BaseDatos,
                    $MovimientosTable,
                    FilaMovimiento
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovimientosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $MovimientosTable,
      FilaMovimiento,
      $$MovimientosTableFilterComposer,
      $$MovimientosTableOrderingComposer,
      $$MovimientosTableAnnotationComposer,
      $$MovimientosTableCreateCompanionBuilder,
      $$MovimientosTableUpdateCompanionBuilder,
      (
        FilaMovimiento,
        BaseReferences<_$BaseDatos, $MovimientosTable, FilaMovimiento>,
      ),
      FilaMovimiento,
      PrefetchHooks Function()
    >;
typedef $$ComprasTableCreateCompanionBuilder = ComprasCompanion Function({
  required String id,
  required DateTime fecha,
  required String proveedor,
  required String factura,
  Value<DateTime?> vence,
  Value<MedioPago?> medio,
  Value<int?> tasa,
  Value<int> rowid,
});
typedef $$ComprasTableUpdateCompanionBuilder = ComprasCompanion Function({
  Value<String> id,
  Value<DateTime> fecha,
  Value<String> proveedor,
  Value<String> factura,
  Value<DateTime?> vence,
  Value<MedioPago?> medio,
  Value<int?> tasa,
  Value<int> rowid,
});

final class $$ComprasTableReferences
    extends BaseReferences<_$BaseDatos, $ComprasTable, FilaCompra> {
  $$ComprasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LineasCompraTable, List<FilaLineaCompra>>
  _lineasCompraRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.lineasCompra,
    aliasName: 'compras__id__lineas_compra__compra_id',
  );

  $$LineasCompraTableProcessedTableManager get lineasCompraRefs {
    final manager = $$LineasCompraTableTableManager(
      $_db,
      $_db.lineasCompra,
    ).filter((f) => f.compraId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineasCompraRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PagosTable, List<FilaPago>> _pagosRefsTable(
    _$BaseDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.pagos,
    aliasName: 'compras__id__pagos__compra_id',
  );

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager(
      $_db,
      $_db.pagos,
    ).filter((f) => f.compraId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComprasTableFilterComposer
    extends Composer<_$BaseDatos, $ComprasTable> {
  $$ComprasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factura => $composableBuilder(
    column: $table.factura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vence => $composableBuilder(
    column: $table.vence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MedioPago?, MedioPago, String> get medio =>
      $composableBuilder(
        column: $table.medio,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lineasCompraRefs(
    Expression<bool> Function($$LineasCompraTableFilterComposer f) f,
  ) {
    final $$LineasCompraTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasCompra,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasCompraTableFilterComposer(
            $db: $db,
            $table: $db.lineasCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pagosRefs(
    Expression<bool> Function($$PagosTableFilterComposer f) f,
  ) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableFilterComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasTableOrderingComposer
    extends Composer<_$BaseDatos, $ComprasTable> {
  $$ComprasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factura => $composableBuilder(
    column: $table.factura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vence => $composableBuilder(
    column: $table.vence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medio => $composableBuilder(
    column: $table.medio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ComprasTableAnnotationComposer
    extends Composer<_$BaseDatos, $ComprasTable> {
  $$ComprasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<String> get factura =>
      $composableBuilder(column: $table.factura, builder: (column) => column);

  GeneratedColumn<DateTime> get vence =>
      $composableBuilder(column: $table.vence, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedioPago?, String> get medio =>
      $composableBuilder(column: $table.medio, builder: (column) => column);

  GeneratedColumn<int> get tasa =>
      $composableBuilder(column: $table.tasa, builder: (column) => column);

  Expression<T> lineasCompraRefs<T extends Object>(
    Expression<T> Function($$LineasCompraTableAnnotationComposer a) f,
  ) {
    final $$LineasCompraTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasCompra,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasCompraTableAnnotationComposer(
            $db: $db,
            $table: $db.lineasCompra,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pagosRefs<T extends Object>(
    Expression<T> Function($$PagosTableAnnotationComposer a) f,
  ) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagos,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $ComprasTable,
          FilaCompra,
          $$ComprasTableFilterComposer,
          $$ComprasTableOrderingComposer,
          $$ComprasTableAnnotationComposer,
          $$ComprasTableCreateCompanionBuilder,
          $$ComprasTableUpdateCompanionBuilder,
          (FilaCompra, $$ComprasTableReferences),
          FilaCompra,
          PrefetchHooks Function({bool lineasCompraRefs, bool pagosRefs})
        > {
  $$ComprasTableTableManager(_$BaseDatos db, $ComprasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> proveedor = const Value.absent(),
                Value<String> factura = const Value.absent(),
                Value<DateTime?> vence = const Value.absent(),
                Value<MedioPago?> medio = const Value.absent(),
                Value<int?> tasa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComprasCompanion(
                id: id,
                fecha: fecha,
                proveedor: proveedor,
                factura: factura,
                vence: vence,
                medio: medio,
                tasa: tasa,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime fecha,
                required String proveedor,
                required String factura,
                Value<DateTime?> vence = const Value.absent(),
                Value<MedioPago?> medio = const Value.absent(),
                Value<int?> tasa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComprasCompanion.insert(
                id: id,
                fecha: fecha,
                proveedor: proveedor,
                factura: factura,
                vence: vence,
                medio: medio,
                tasa: tasa,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ComprasTable, FilaCompra>(table),
                  $$ComprasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({lineasCompraRefs = false, pagosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lineasCompraRefs) db.lineasCompra,
                    if (pagosRefs) db.pagos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lineasCompraRefs)
                        await $_getPrefetchedDataByColumns<
                          FilaCompra,
                          $ComprasTable,
                          FilaLineaCompra,
                          $LineasCompraTable
                        >(
                          currentTable: table,
                          referencedTable: $$ComprasTableReferences
                              ._lineasCompraRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComprasTableReferences(
                                db,
                                table,
                                p0,
                              ).lineasCompraRefs,
                          currentColumn: 'id',
                          referencedColumn: 'compra_id',
                          typedResults: items,
                        ),
                      if (pagosRefs)
                        await $_getPrefetchedDataByColumns<
                          FilaCompra,
                          $ComprasTable,
                          FilaPago,
                          $PagosTable
                        >(
                          currentTable: table,
                          referencedTable: $$ComprasTableReferences
                              ._pagosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComprasTableReferences(db, table, p0).pagosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'compra_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ComprasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $ComprasTable,
      FilaCompra,
      $$ComprasTableFilterComposer,
      $$ComprasTableOrderingComposer,
      $$ComprasTableAnnotationComposer,
      $$ComprasTableCreateCompanionBuilder,
      $$ComprasTableUpdateCompanionBuilder,
      (FilaCompra, $$ComprasTableReferences),
      FilaCompra,
      PrefetchHooks Function({bool lineasCompraRefs, bool pagosRefs})
    >;
typedef $$LineasCompraTableCreateCompanionBuilder =
    LineasCompraCompanion Function({
      Value<int> id,
      required String compraId,
      required int orden,
      required String productoId,
      required String producto,
      required FormaConteo forma,
      required String marca,
      required int piezas,
      required int cantidad,
      required int costo,
    });
typedef $$LineasCompraTableUpdateCompanionBuilder =
    LineasCompraCompanion Function({
      Value<int> id,
      Value<String> compraId,
      Value<int> orden,
      Value<String> productoId,
      Value<String> producto,
      Value<FormaConteo> forma,
      Value<String> marca,
      Value<int> piezas,
      Value<int> cantidad,
      Value<int> costo,
    });

final class $$LineasCompraTableReferences
    extends BaseReferences<_$BaseDatos, $LineasCompraTable, FilaLineaCompra> {
  $$LineasCompraTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ComprasTable _compraIdTable(_$BaseDatos db) =>
      db.compras.createAlias('lineas_compra__compra_id__compras__id');

  $$ComprasTableProcessedTableManager get compraId {
    final $_column = $_itemColumn<String>('compra_id')!;

    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LineasCompraTableFilterComposer
    extends Composer<_$BaseDatos, $LineasCompraTable> {
  $$LineasCompraTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FormaConteo, FormaConteo, String> get forma =>
      $composableBuilder(
        column: $table.forma,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  $$ComprasTableFilterComposer get compraId {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasCompraTableOrderingComposer
    extends Composer<_$BaseDatos, $LineasCompraTable> {
  $$LineasCompraTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forma => $composableBuilder(
    column: $table.forma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get piezas => $composableBuilder(
    column: $table.piezas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComprasTableOrderingComposer get compraId {
    final $$ComprasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableOrderingComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasCompraTableAnnotationComposer
    extends Composer<_$BaseDatos, $LineasCompraTable> {
  $$LineasCompraTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormaConteo, String> get forma =>
      $composableBuilder(column: $table.forma, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<int> get piezas =>
      $composableBuilder(column: $table.piezas, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  $$ComprasTableAnnotationComposer get compraId {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasCompraTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $LineasCompraTable,
          FilaLineaCompra,
          $$LineasCompraTableFilterComposer,
          $$LineasCompraTableOrderingComposer,
          $$LineasCompraTableAnnotationComposer,
          $$LineasCompraTableCreateCompanionBuilder,
          $$LineasCompraTableUpdateCompanionBuilder,
          (FilaLineaCompra, $$LineasCompraTableReferences),
          FilaLineaCompra,
          PrefetchHooks Function({bool compraId})
        > {
  $$LineasCompraTableTableManager(_$BaseDatos db, $LineasCompraTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineasCompraTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineasCompraTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineasCompraTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> compraId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<String> producto = const Value.absent(),
                Value<FormaConteo> forma = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<int> piezas = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int> costo = const Value.absent(),
              }) => LineasCompraCompanion(
                id: id,
                compraId: compraId,
                orden: orden,
                productoId: productoId,
                producto: producto,
                forma: forma,
                marca: marca,
                piezas: piezas,
                cantidad: cantidad,
                costo: costo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String compraId,
                required int orden,
                required String productoId,
                required String producto,
                required FormaConteo forma,
                required String marca,
                required int piezas,
                required int cantidad,
                required int costo,
              }) => LineasCompraCompanion.insert(
                id: id,
                compraId: compraId,
                orden: orden,
                productoId: productoId,
                producto: producto,
                forma: forma,
                marca: marca,
                piezas: piezas,
                cantidad: cantidad,
                costo: costo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineasCompraTable, FilaLineaCompra>(table),
                  $$LineasCompraTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compraId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compraId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.compraId,
                        referencedTable: $$LineasCompraTableReferences
                            ._compraIdTable(db),
                        referencedColumn: $$LineasCompraTableReferences
                            ._compraIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LineasCompraTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $LineasCompraTable,
      FilaLineaCompra,
      $$LineasCompraTableFilterComposer,
      $$LineasCompraTableOrderingComposer,
      $$LineasCompraTableAnnotationComposer,
      $$LineasCompraTableCreateCompanionBuilder,
      $$LineasCompraTableUpdateCompanionBuilder,
      (FilaLineaCompra, $$LineasCompraTableReferences),
      FilaLineaCompra,
      PrefetchHooks Function({bool compraId})
    >;
typedef $$PagosTableCreateCompanionBuilder = PagosCompanion Function({
  required String id,
  required String compraId,
  required DateTime fecha,
  required MedioPago medio,
  required int monto,
  required int entregado,
  Value<int?> tasa,
  required String referencia,
  Value<int> rowid,
});
typedef $$PagosTableUpdateCompanionBuilder = PagosCompanion Function({
  Value<String> id,
  Value<String> compraId,
  Value<DateTime> fecha,
  Value<MedioPago> medio,
  Value<int> monto,
  Value<int> entregado,
  Value<int?> tasa,
  Value<String> referencia,
  Value<int> rowid,
});

final class $$PagosTableReferences
    extends BaseReferences<_$BaseDatos, $PagosTable, FilaPago> {
  $$PagosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ComprasTable _compraIdTable(_$BaseDatos db) =>
      db.compras.createAlias('pagos__compra_id__compras__id');

  $$ComprasTableProcessedTableManager get compraId {
    final $_column = $_itemColumn<String>('compra_id')!;

    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagosTableFilterComposer extends Composer<_$BaseDatos, $PagosTable> {
  $$PagosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MedioPago, MedioPago, String> get medio =>
      $composableBuilder(
        column: $table.medio,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entregado => $composableBuilder(
    column: $table.entregado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnFilters(column),
  );

  $$ComprasTableFilterComposer get compraId {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosTableOrderingComposer extends Composer<_$BaseDatos, $PagosTable> {
  $$PagosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medio => $composableBuilder(
    column: $table.medio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entregado => $composableBuilder(
    column: $table.entregado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComprasTableOrderingComposer get compraId {
    final $$ComprasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableOrderingComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosTableAnnotationComposer
    extends Composer<_$BaseDatos, $PagosTable> {
  $$PagosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedioPago, String> get medio =>
      $composableBuilder(column: $table.medio, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<int> get entregado =>
      $composableBuilder(column: $table.entregado, builder: (column) => column);

  GeneratedColumn<int> get tasa =>
      $composableBuilder(column: $table.tasa, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => column,
  );

  $$ComprasTableAnnotationComposer get compraId {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $PagosTable,
          FilaPago,
          $$PagosTableFilterComposer,
          $$PagosTableOrderingComposer,
          $$PagosTableAnnotationComposer,
          $$PagosTableCreateCompanionBuilder,
          $$PagosTableUpdateCompanionBuilder,
          (FilaPago, $$PagosTableReferences),
          FilaPago,
          PrefetchHooks Function({bool compraId})
        > {
  $$PagosTableTableManager(_$BaseDatos db, $PagosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> compraId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<MedioPago> medio = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<int> entregado = const Value.absent(),
                Value<int?> tasa = const Value.absent(),
                Value<String> referencia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagosCompanion(
                id: id,
                compraId: compraId,
                fecha: fecha,
                medio: medio,
                monto: monto,
                entregado: entregado,
                tasa: tasa,
                referencia: referencia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String compraId,
                required DateTime fecha,
                required MedioPago medio,
                required int monto,
                required int entregado,
                Value<int?> tasa = const Value.absent(),
                required String referencia,
                Value<int> rowid = const Value.absent(),
              }) => PagosCompanion.insert(
                id: id,
                compraId: compraId,
                fecha: fecha,
                medio: medio,
                monto: monto,
                entregado: entregado,
                tasa: tasa,
                referencia: referencia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagosTable, FilaPago>(table),
                  $$PagosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compraId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compraId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.compraId,
                        referencedTable: $$PagosTableReferences._compraIdTable(
                          db,
                        ),
                        referencedColumn: $$PagosTableReferences
                            ._compraIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PagosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $PagosTable,
      FilaPago,
      $$PagosTableFilterComposer,
      $$PagosTableOrderingComposer,
      $$PagosTableAnnotationComposer,
      $$PagosTableCreateCompanionBuilder,
      $$PagosTableUpdateCompanionBuilder,
      (FilaPago, $$PagosTableReferences),
      FilaPago,
      PrefetchHooks Function({bool compraId})
    >;
typedef $$VentasTableCreateCompanionBuilder = VentasCompanion Function({
  required String id,
  required DateTime fecha,
  required int total,
  Value<int?> tasa,
  Value<int> rowid,
});
typedef $$VentasTableUpdateCompanionBuilder = VentasCompanion Function({
  Value<String> id,
  Value<DateTime> fecha,
  Value<int> total,
  Value<int?> tasa,
  Value<int> rowid,
});

final class $$VentasTableReferences
    extends BaseReferences<_$BaseDatos, $VentasTable, FilaVenta> {
  $$VentasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PagosVentaTable, List<FilaPagoVenta>>
  _pagosVentaRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.pagosVenta,
    aliasName: 'ventas__id__pagos_venta__venta_id',
  );

  $$PagosVentaTableProcessedTableManager get pagosVentaRefs {
    final manager = $$PagosVentaTableTableManager(
      $_db,
      $_db.pagosVenta,
    ).filter((f) => f.ventaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosVentaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VentasTableFilterComposer extends Composer<_$BaseDatos, $VentasTable> {
  $$VentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pagosVentaRefs(
    Expression<bool> Function($$PagosVentaTableFilterComposer f) f,
  ) {
    final $$PagosVentaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosVentaTableFilterComposer(
            $db: $db,
            $table: $db.pagosVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableOrderingComposer
    extends Composer<_$BaseDatos, $VentasTable> {
  $$VentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasTableAnnotationComposer
    extends Composer<_$BaseDatos, $VentasTable> {
  $$VentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get tasa =>
      $composableBuilder(column: $table.tasa, builder: (column) => column);

  Expression<T> pagosVentaRefs<T extends Object>(
    Expression<T> Function($$PagosVentaTableAnnotationComposer a) f,
  ) {
    final $$PagosVentaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosVenta,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosVentaTableAnnotationComposer(
            $db: $db,
            $table: $db.pagosVenta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $VentasTable,
          FilaVenta,
          $$VentasTableFilterComposer,
          $$VentasTableOrderingComposer,
          $$VentasTableAnnotationComposer,
          $$VentasTableCreateCompanionBuilder,
          $$VentasTableUpdateCompanionBuilder,
          (FilaVenta, $$VentasTableReferences),
          FilaVenta,
          PrefetchHooks Function({bool pagosVentaRefs})
        > {
  $$VentasTableTableManager(_$BaseDatos db, $VentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int?> tasa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion(
                id: id,
                fecha: fecha,
                total: total,
                tasa: tasa,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime fecha,
                required int total,
                Value<int?> tasa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion.insert(
                id: id,
                fecha: fecha,
                total: total,
                tasa: tasa,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VentasTable, FilaVenta>(table),
                  $$VentasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pagosVentaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (pagosVentaRefs) db.pagosVenta],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pagosVentaRefs)
                    await $_getPrefetchedDataByColumns<
                      FilaVenta,
                      $VentasTable,
                      FilaPagoVenta,
                      $PagosVentaTable
                    >(
                      currentTable: table,
                      referencedTable: $$VentasTableReferences
                          ._pagosVentaRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VentasTableReferences(db, table, p0).pagosVentaRefs,
                      currentColumn: 'id',
                      referencedColumn: 'venta_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VentasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $VentasTable,
      FilaVenta,
      $$VentasTableFilterComposer,
      $$VentasTableOrderingComposer,
      $$VentasTableAnnotationComposer,
      $$VentasTableCreateCompanionBuilder,
      $$VentasTableUpdateCompanionBuilder,
      (FilaVenta, $$VentasTableReferences),
      FilaVenta,
      PrefetchHooks Function({bool pagosVentaRefs})
    >;
typedef $$PagosVentaTableCreateCompanionBuilder = PagosVentaCompanion Function({
  required String ventaId,
  required int orden,
  required MedioPago medio,
  required int monto,
  required String referencia,
  Value<int> rowid,
});
typedef $$PagosVentaTableUpdateCompanionBuilder = PagosVentaCompanion Function({
  Value<String> ventaId,
  Value<int> orden,
  Value<MedioPago> medio,
  Value<int> monto,
  Value<String> referencia,
  Value<int> rowid,
});

final class $$PagosVentaTableReferences
    extends BaseReferences<_$BaseDatos, $PagosVentaTable, FilaPagoVenta> {
  $$PagosVentaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VentasTable _ventaIdTable(_$BaseDatos db) =>
      db.ventas.createAlias('pagos_venta__venta_id__ventas__id');

  $$VentasTableProcessedTableManager get ventaId {
    final $_column = $_itemColumn<String>('venta_id')!;

    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagosVentaTableFilterComposer
    extends Composer<_$BaseDatos, $PagosVentaTable> {
  $$PagosVentaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MedioPago, MedioPago, String> get medio =>
      $composableBuilder(
        column: $table.medio,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnFilters(column),
  );

  $$VentasTableFilterComposer get ventaId {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosVentaTableOrderingComposer
    extends Composer<_$BaseDatos, $PagosVentaTable> {
  $$PagosVentaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medio => $composableBuilder(
    column: $table.medio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnOrderings(column),
  );

  $$VentasTableOrderingComposer get ventaId {
    final $$VentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableOrderingComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosVentaTableAnnotationComposer
    extends Composer<_$BaseDatos, $PagosVentaTable> {
  $$PagosVentaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedioPago, String> get medio =>
      $composableBuilder(column: $table.medio, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => column,
  );

  $$VentasTableAnnotationComposer get ventaId {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosVentaTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $PagosVentaTable,
          FilaPagoVenta,
          $$PagosVentaTableFilterComposer,
          $$PagosVentaTableOrderingComposer,
          $$PagosVentaTableAnnotationComposer,
          $$PagosVentaTableCreateCompanionBuilder,
          $$PagosVentaTableUpdateCompanionBuilder,
          (FilaPagoVenta, $$PagosVentaTableReferences),
          FilaPagoVenta,
          PrefetchHooks Function({bool ventaId})
        > {
  $$PagosVentaTableTableManager(_$BaseDatos db, $PagosVentaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosVentaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosVentaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosVentaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ventaId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<MedioPago> medio = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<String> referencia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagosVentaCompanion(
                ventaId: ventaId,
                orden: orden,
                medio: medio,
                monto: monto,
                referencia: referencia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ventaId,
                required int orden,
                required MedioPago medio,
                required int monto,
                required String referencia,
                Value<int> rowid = const Value.absent(),
              }) => PagosVentaCompanion.insert(
                ventaId: ventaId,
                orden: orden,
                medio: medio,
                monto: monto,
                referencia: referencia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagosVentaTable, FilaPagoVenta>(table),
                  $$PagosVentaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ventaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ventaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.ventaId,
                        referencedTable: $$PagosVentaTableReferences
                            ._ventaIdTable(db),
                        referencedColumn: $$PagosVentaTableReferences
                            ._ventaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PagosVentaTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $PagosVentaTable,
      FilaPagoVenta,
      $$PagosVentaTableFilterComposer,
      $$PagosVentaTableOrderingComposer,
      $$PagosVentaTableAnnotationComposer,
      $$PagosVentaTableCreateCompanionBuilder,
      $$PagosVentaTableUpdateCompanionBuilder,
      (FilaPagoVenta, $$PagosVentaTableReferences),
      FilaPagoVenta,
      PrefetchHooks Function({bool ventaId})
    >;
typedef $$CajasTableCreateCompanionBuilder = CajasCompanion Function({
  required String id,
  required DateTime abierta,
  required int fondoDolares,
  required int fondoBolivares,
  Value<DateTime?> cerrada,
  required String contado,
  required String nota,
  Value<int> rowid,
});
typedef $$CajasTableUpdateCompanionBuilder = CajasCompanion Function({
  Value<String> id,
  Value<DateTime> abierta,
  Value<int> fondoDolares,
  Value<int> fondoBolivares,
  Value<DateTime?> cerrada,
  Value<String> contado,
  Value<String> nota,
  Value<int> rowid,
});

class $$CajasTableFilterComposer extends Composer<_$BaseDatos, $CajasTable> {
  $$CajasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get abierta => $composableBuilder(
    column: $table.abierta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fondoDolares => $composableBuilder(
    column: $table.fondoDolares,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fondoBolivares => $composableBuilder(
    column: $table.fondoBolivares,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cerrada => $composableBuilder(
    column: $table.cerrada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contado => $composableBuilder(
    column: $table.contado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CajasTableOrderingComposer extends Composer<_$BaseDatos, $CajasTable> {
  $$CajasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get abierta => $composableBuilder(
    column: $table.abierta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fondoDolares => $composableBuilder(
    column: $table.fondoDolares,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fondoBolivares => $composableBuilder(
    column: $table.fondoBolivares,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cerrada => $composableBuilder(
    column: $table.cerrada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contado => $composableBuilder(
    column: $table.contado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CajasTableAnnotationComposer
    extends Composer<_$BaseDatos, $CajasTable> {
  $$CajasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get abierta =>
      $composableBuilder(column: $table.abierta, builder: (column) => column);

  GeneratedColumn<int> get fondoDolares => $composableBuilder(
    column: $table.fondoDolares,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fondoBolivares => $composableBuilder(
    column: $table.fondoBolivares,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cerrada =>
      $composableBuilder(column: $table.cerrada, builder: (column) => column);

  GeneratedColumn<String> get contado =>
      $composableBuilder(column: $table.contado, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);
}

class $$CajasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $CajasTable,
          FilaCaja,
          $$CajasTableFilterComposer,
          $$CajasTableOrderingComposer,
          $$CajasTableAnnotationComposer,
          $$CajasTableCreateCompanionBuilder,
          $$CajasTableUpdateCompanionBuilder,
          (FilaCaja, BaseReferences<_$BaseDatos, $CajasTable, FilaCaja>),
          FilaCaja,
          PrefetchHooks Function()
        > {
  $$CajasTableTableManager(_$BaseDatos db, $CajasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CajasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CajasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CajasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> abierta = const Value.absent(),
                Value<int> fondoDolares = const Value.absent(),
                Value<int> fondoBolivares = const Value.absent(),
                Value<DateTime?> cerrada = const Value.absent(),
                Value<String> contado = const Value.absent(),
                Value<String> nota = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CajasCompanion(
                id: id,
                abierta: abierta,
                fondoDolares: fondoDolares,
                fondoBolivares: fondoBolivares,
                cerrada: cerrada,
                contado: contado,
                nota: nota,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime abierta,
                required int fondoDolares,
                required int fondoBolivares,
                Value<DateTime?> cerrada = const Value.absent(),
                required String contado,
                required String nota,
                Value<int> rowid = const Value.absent(),
              }) => CajasCompanion.insert(
                id: id,
                abierta: abierta,
                fondoDolares: fondoDolares,
                fondoBolivares: fondoBolivares,
                cerrada: cerrada,
                contado: contado,
                nota: nota,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CajasTable, FilaCaja>(table),
                  BaseReferences<_$BaseDatos, $CajasTable, FilaCaja>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CajasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $CajasTable,
      FilaCaja,
      $$CajasTableFilterComposer,
      $$CajasTableOrderingComposer,
      $$CajasTableAnnotationComposer,
      $$CajasTableCreateCompanionBuilder,
      $$CajasTableUpdateCompanionBuilder,
      (FilaCaja, BaseReferences<_$BaseDatos, $CajasTable, FilaCaja>),
      FilaCaja,
      PrefetchHooks Function()
    >;
typedef $$GastosTableCreateCompanionBuilder = GastosCompanion Function({
  required String id,
  required DateTime fecha,
  required CategoriaGasto categoria,
  required MedioPago medio,
  required int monto,
  Value<int?> tasa,
  required String nota,
  Value<int> rowid,
});
typedef $$GastosTableUpdateCompanionBuilder = GastosCompanion Function({
  Value<String> id,
  Value<DateTime> fecha,
  Value<CategoriaGasto> categoria,
  Value<MedioPago> medio,
  Value<int> monto,
  Value<int?> tasa,
  Value<String> nota,
  Value<int> rowid,
});

class $$GastosTableFilterComposer extends Composer<_$BaseDatos, $GastosTable> {
  $$GastosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoriaGasto, CategoriaGasto, String>
  get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MedioPago, MedioPago, String> get medio =>
      $composableBuilder(
        column: $table.medio,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GastosTableOrderingComposer
    extends Composer<_$BaseDatos, $GastosTable> {
  $$GastosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medio => $composableBuilder(
    column: $table.medio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tasa => $composableBuilder(
    column: $table.tasa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GastosTableAnnotationComposer
    extends Composer<_$BaseDatos, $GastosTable> {
  $$GastosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoriaGasto, String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedioPago, String> get medio =>
      $composableBuilder(column: $table.medio, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<int> get tasa =>
      $composableBuilder(column: $table.tasa, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);
}

class $$GastosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $GastosTable,
          FilaGasto,
          $$GastosTableFilterComposer,
          $$GastosTableOrderingComposer,
          $$GastosTableAnnotationComposer,
          $$GastosTableCreateCompanionBuilder,
          $$GastosTableUpdateCompanionBuilder,
          (FilaGasto, BaseReferences<_$BaseDatos, $GastosTable, FilaGasto>),
          FilaGasto,
          PrefetchHooks Function()
        > {
  $$GastosTableTableManager(_$BaseDatos db, $GastosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GastosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GastosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GastosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<CategoriaGasto> categoria = const Value.absent(),
                Value<MedioPago> medio = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<int?> tasa = const Value.absent(),
                Value<String> nota = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GastosCompanion(
                id: id,
                fecha: fecha,
                categoria: categoria,
                medio: medio,
                monto: monto,
                tasa: tasa,
                nota: nota,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime fecha,
                required CategoriaGasto categoria,
                required MedioPago medio,
                required int monto,
                Value<int?> tasa = const Value.absent(),
                required String nota,
                Value<int> rowid = const Value.absent(),
              }) => GastosCompanion.insert(
                id: id,
                fecha: fecha,
                categoria: categoria,
                medio: medio,
                monto: monto,
                tasa: tasa,
                nota: nota,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GastosTable, FilaGasto>(table),
                  BaseReferences<_$BaseDatos, $GastosTable, FilaGasto>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GastosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $GastosTable,
      FilaGasto,
      $$GastosTableFilterComposer,
      $$GastosTableOrderingComposer,
      $$GastosTableAnnotationComposer,
      $$GastosTableCreateCompanionBuilder,
      $$GastosTableUpdateCompanionBuilder,
      (FilaGasto, BaseReferences<_$BaseDatos, $GastosTable, FilaGasto>),
      FilaGasto,
      PrefetchHooks Function()
    >;

class $BaseDatosManager {
  final _$BaseDatos _db;
  $BaseDatosManager(this._db);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$LotesMarcaTableTableManager get lotesMarca =>
      $$LotesMarcaTableTableManager(_db, _db.lotesMarca);
  $$PresentacionesTableTableManager get presentaciones =>
      $$PresentacionesTableTableManager(_db, _db.presentaciones);
  $$ProveedoresTableTableManager get proveedores =>
      $$ProveedoresTableTableManager(_db, _db.proveedores);
  $$IncidenciasTableTableManager get incidencias =>
      $$IncidenciasTableTableManager(_db, _db.incidencias);
  $$MovimientosTableTableManager get movimientos =>
      $$MovimientosTableTableManager(_db, _db.movimientos);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db, _db.compras);
  $$LineasCompraTableTableManager get lineasCompra =>
      $$LineasCompraTableTableManager(_db, _db.lineasCompra);
  $$PagosTableTableManager get pagos =>
      $$PagosTableTableManager(_db, _db.pagos);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$PagosVentaTableTableManager get pagosVenta =>
      $$PagosVentaTableTableManager(_db, _db.pagosVenta);
  $$CajasTableTableManager get cajas =>
      $$CajasTableTableManager(_db, _db.cajas);
  $$GastosTableTableManager get gastos =>
      $$GastosTableTableManager(_db, _db.gastos);
}
